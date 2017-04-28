//
//  VoiceCollectionViewCell.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class VoiceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
   
    var foodItem: TTFoodItem! {
        didSet {
            foodNameLabel.text = foodItem.name
            if let imageurlstring = foodItem.images?[0] {
                if let data = try? Data(contentsOf: imageurlstring) {
                    foodImageView.image = UIImage(data: data)
                }
            }
        }
    }
    
}
