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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var reward: TTReward! {
        didSet {
            guard reward != nil else {
                return
            }

            pointsLabel.text = "\(String(describing: reward.points!))"

            if let rewardImageUrl = reward.thumbnailURL {
                rewardImageView.setImageWith(rewardImageUrl)
            }
        }
    }

    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            rewardImageView.layer.borderWidth = isSelected ? 1 : 0
        }
    }

    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        rewardImageView.layer.borderColor = themeColor.cgColor
        rewardImageView.layer.cornerRadius = 3
        isSelected = false
    }
}
