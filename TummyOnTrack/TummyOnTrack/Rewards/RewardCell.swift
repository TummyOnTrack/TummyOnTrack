//
//  RewardCell.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class RewardCell: UICollectionViewCell {
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var rewardLabel: UILabel!

    var reward: TTReward! {
        didSet {
            guard reward != nil else {
                return
            }

            pointsLabel.text = "\(String(describing: reward.points!))"
            rewardLabel.text = reward.name

            if let rewardImageUrl = reward.imageURLs?.first {
                rewardImageView.setImageWith(rewardImageUrl)
            }
        }
    }
}
