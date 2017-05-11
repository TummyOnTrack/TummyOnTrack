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
    
    var isSelectedForDeletion = false
   
    var foodItem: TTFoodItem! {
        didSet {
            foodCellView.layer.cornerRadius = 5
            foodNameLabel.text = foodItem.name
            deleteImage.isHidden = true
            if let imageurlstring = foodItem.images?[0] {
                /*if let data = try? Data(contentsOf: imageurlstring) {
                    foodImageView.image = UIImage(data: data)
                }*/
                foodImageView.sd_setImage(with: imageurlstring)
            }
        }
    }
    
    func selectToDelete() {
        if isSelectedForDeletion {
            isSelectedForDeletion = false
            foodCellView.layer.borderColor = UIColor.clear.cgColor
            deleteImage.isHidden = true
        }
        else {
            isSelectedForDeletion = true
            foodCellView.layer.borderColor = UIColor.red.cgColor
            foodCellView.layer.borderWidth = 1
            deleteImage.isHidden = false
        }
    }
    
}
