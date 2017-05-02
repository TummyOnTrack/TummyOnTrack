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

    var rewards = [TTReward]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        // Add temp rewards
//        let rewardsImages = ["Cat", "Duckling", "Gorilla", "Hippo", "Panda", "Rabbit", "Raccoon"]
//        var points = 10
//        for rewardImage in rewardsImages {
//            TTReward.addReward(filename: rewardImage, points: points)
//            points += 5
//        }

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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RewardCell", for: indexPath) as! RewardCell
        cell.reward = rewards[indexPath.row]

        return cell
    }
}

extension TTRewardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected reward at: \(indexPath.row)")
    }
}
