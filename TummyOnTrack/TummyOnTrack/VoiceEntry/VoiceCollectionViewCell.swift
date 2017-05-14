//
//  VoiceCollectionViewCell.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import SDWebImage

class VoiceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var deleteImage: UIImageView!
    @IBOutlet weak var foodCellView: UIView!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!

    var isSelectedFoodItem: Bool! {
        didSet {
            if isSelectedFoodItem == true {
                deleteImage.image = UIImage(named: "tickmark")
            }
            else {
                deleteImage.image = UIImage(named: "delete")
            }
        }
    }
   
    var foodItem: TTFoodItem! {
        didSet {
            foodCellView.layer.cornerRadius = 5
            foodNameLabel.text = foodItem.name
         //   deleteImage.isHidden = true
            if let imageurlstring = foodItem.images?[0] {
                /*if let data = try? Data(contentsOf: imageurlstring) {
                    foodImageView.image = UIImage(data: data)
                }*/
                foodImageView.sd_setImage(with: imageurlstring)
            }
            deleteImage.image = UIImage(named: "tickmark")
        }
    }
    
    func deleteOrSelect(isSelected: Bool) {
        if isSelected {
            deleteImage.image = UIImage(named: "tickmark")
        }
        else {
            deleteImage.image = UIImage(named: "delete")
        }
    }
    
}
