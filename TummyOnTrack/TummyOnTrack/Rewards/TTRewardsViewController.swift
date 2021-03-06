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

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var headerLabel: UILabel!

    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 10.0, bottom: 50.0, right: 10.0)
    fileprivate let reuseIdentifier = "RewardCell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate var selectedRewards = [TTReward]()
    fileprivate let usedPointsTextLabel = UILabel()
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

    var buying: Bool = false {
        didSet {
            collectionView?.allowsMultipleSelection = buying
            collectionView?.selectItem(at: nil, animated: true, scrollPosition: UICollectionViewScrollPosition())
            selectedRewards.removeAll(keepingCapacity: false)

            guard let buyButton = self.navigationItem.rightBarButtonItems?.first else {
                return
            }

            guard buying else {
                buyButton.title = "Select"
                navigationItem.setRightBarButtonItems([buyButton], animated: true)
                return
            }

            if let _ = largePhotoIndexPath  {
                largePhotoIndexPath = nil
            }

            updateSelectedRewardsCount()
            let buyingDetailItem = UIBarButtonItem(customView: usedPointsTextLabel)
            buyButton.title = "Buy"
            navigationItem.setRightBarButtonItems([buyButton, buyingDetailItem], animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        loadRewards()
    }

    func loadRewards() {
        TTReward.getRewards(success: { (rewards: [TTReward]) in
            self.rewards = rewards
            let unusedPoints = TTProfile.currentProfile == nil ? 0 : TTProfile.currentProfile!.unusedPoints
            self.headerLabel.text = "You have \(String(describing: unusedPoints)) points"
            self.collectionView.reloadData()
        }, failure: { (error: Error) -> ()  in
            print("Failed to load rewards")
        })
    }
    
    func getRemainingUnusedPoints() -> Int {
        var remainingPoints = TTProfile.currentProfile?.unusedPoints
        for reward in selectedRewards {
            remainingPoints = remainingPoints! - reward.points!
        }
        return remainingPoints!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buy(_ sender: UIBarButtonItem) {
        guard !rewards.isEmpty else {
            return
        }

        guard !selectedRewards.isEmpty else {

            buying = !buying
            if sender.title! == "Buy"  {
                headerLabel.text = "Start tapping rewards you want to buy👇"
            }
            else {
                if let unusedPoints = TTProfile.currentProfile?.unusedPoints {
                    self.headerLabel.text = "You have \(String(describing: unusedPoints)) points"
                }
            }
            return
        }

        guard buying else  {
            return
        }

        var pointsUsed = 0
        for selectedReward in selectedRewards {
            if let points = selectedReward.points {
                pointsUsed += points
            }
        }

        if let unusedPoints = TTProfile.currentProfile?.unusedPoints {
            if pointsUsed > 0 && unusedPoints >= pointsUsed {
                TTProfile.currentProfile!.updateRewards(unusedPoints: (unusedPoints - pointsUsed), rewards: selectedRewards, success: {
                    print("You just used \(pointsUsed) to buy rewards")
                }, failure: { (Error) in
                    print("Unable to update rewards!")
                })

                buying = false

                let rewardsStoryboard = UIStoryboard(name: "Rewards", bundle: nil)
                let decorateMyRoomVC = rewardsStoryboard.instantiateViewController(withIdentifier: "DecorateMyRoom") as! TTDecorateRoomViewController
                navigationController?.pushViewController(decorateMyRoomVC, animated: true)
            } else {
                print("You have \(unusedPoints) points, but have selected items worth \(pointsUsed)")
                headerLabel.text = "Oops! you don't have enough points😟"
            }
        } else {
            print("You don't have a saved profile or unused points")
        }
    }
}

extension TTRewardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RewardCell
        cell.reward = rewardForIndexPath(indexPath)
        
        if let unusedPoints = TTProfile.currentProfile?.unusedPoints {
            if unusedPoints < cell.reward.points! {
                cell.alpha = 0.5
            }
            else {
                cell.alpha = 1
            }
        }
        
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

extension TTRewardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard !buying else {
            return true
        }

        largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
        return false
    }

    func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        guard buying else {
            return
        }

        if let unusedPoints = TTProfile.currentProfile?.unusedPoints {
            if unusedPoints < rewardForIndexPath(indexPath).points! {
                
                return
            }
        }

        let photo = rewardForIndexPath(indexPath)
        selectedRewards.append(photo)
        updateSelectedRewardsCount()
    }

    func collectionView(_ collectionView: UICollectionView,
                                 didDeselectItemAt indexPath: IndexPath) {

        guard buying else {
            return
        }

        let photo = rewardForIndexPath(indexPath)

        if let index = selectedRewards.index(of: photo) {
            selectedRewards.remove(at: index)
            updateSelectedRewardsCount()
        }
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

// MARK: - Private
private extension TTRewardsViewController {
    func rewardForIndexPath(_ indexPath: IndexPath) -> TTReward {
        return rewards[indexPath.row]
    }

    func updateSelectedRewardsCount() {
        let remainingPoints = getRemainingUnusedPoints()
        if remainingPoints < 0 {
            headerLabel.text = "Oops! you don't have enough points😟"
        }
        else {
            headerLabel.text = "You have " + "\(getRemainingUnusedPoints())" + " points"
        }
        usedPointsTextLabel.textColor = themeColor
        usedPointsTextLabel.text = "\(selectedRewards.count) rewards selected"
        usedPointsTextLabel.sizeToFit()
    }
}
