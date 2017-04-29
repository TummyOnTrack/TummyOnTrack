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

    var rewards: [TTReward]!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        rewards = [TTReward]()

        // load default food items
        let ref = FIRDatabase.database().reference(fromURL: "https://tummyontrack.firebaseio.com/").child("Rewards")
        let query = ref.queryOrdered(byChild: "name")
        query.observeSingleEvent(of: .value, with: { snapshot in
            for snap in snapshot.children {
                let snap_ = snap as! FIRDataSnapshot
                let dict = snap_.value as! NSDictionary
                let reward = TTReward(dictionary: dict)
                self.rewards.append(reward)
            }
        })

        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TTRewardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewards == nil ? 0 : rewards!.count
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
