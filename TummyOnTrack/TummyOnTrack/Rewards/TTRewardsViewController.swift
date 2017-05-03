//
//  TTRewardsViewController.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTRewardsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let reuseIdentifier = "RewardCell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate var rewards = [TTReward]()

    fileprivate var largePhotoIndexPath: IndexPath? {
        didSet {
            var indexPaths = [IndexPath]()
            if let largePhotoIndexPath = largePhotoIndexPath {
                indexPaths.append(largePhotoIndexPath)
            }
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }

            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItems(at: indexPaths)
            }) { completed in
                if let largePhotoIndexPath = self.largePhotoIndexPath {
                    self.collectionView?.scrollToItem(
                        at: largePhotoIndexPath,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        // Load reward items
        loadRewards()
    }

    func loadRewards() {
        TTReward.getRewards(success: { (rewards: [TTReward]) in
            self.rewards = rewards
            self.collectionView.reloadData()
        }, failure: { (error: Error) -> ()  in
            print("Failed to load rewards")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TTRewardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewards.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "RewardsHeaderView",
                                                                             for: indexPath) as! RewardsHeaderView
            headerView.pointsLabel.text = "You have \(String(describing: TTProfile.currentProfile!.unusedPoints)) points"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RewardCell
        cell.reward = rewardForIndexPath(indexPath)

        cell.activityIndicator.stopAnimating()

        guard indexPath == largePhotoIndexPath else {
            cell.activityIndicator.startAnimating()
            cell.rewardImageView.setImageWith(cell.reward.thumbnailURL!)
            cell.activityIndicator.stopAnimating()
            return cell
        }

        guard cell.reward.largeImageURL == nil else {
            cell.activityIndicator.startAnimating()
            cell.rewardImageView.setImageWith(cell.reward.largeImageURL!)
            cell.activityIndicator.stopAnimating()
            return cell
        }

        cell.activityIndicator.startAnimating()
        cell.rewardImageView.setImageWith(cell.reward.thumbnailURL!)
        cell.activityIndicator.stopAnimating()

        return cell
    }
}

// MARK: - Private
private extension TTRewardsViewController {
    func rewardForIndexPath(_ indexPath: IndexPath) -> TTReward {
        return rewards[indexPath.row]
    }

//    func updateSharedPhotoCount() {
//        shareTextLabel.textColor = themeColor
//        shareTextLabel.text = "\(selectedPhotos.count) photos selected"
//        shareTextLabel.sizeToFit()
//    }
}

extension TTRewardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected reward at: \(indexPath.row)")
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
        return false
    }
}

extension TTRewardsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath == largePhotoIndexPath {
            let reward = rewardForIndexPath(indexPath)
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)

            return reward.sizeToFillWidthOfSize(size)
        }

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
