//
//  VoiceCollectionViewCell.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import SDWebImage

protocol VoiceCollectionCellDelegate {

    func deleteFoodItem( aFoodItem: TTFoodItem)

}

class VoiceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var deleteImage: UIImageView!
    @IBOutlet weak var foodCellView: UIView!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: VoiceCollectionCellDelegate?
    
    var isSelectedFoodItem: Bool! {
        didSet {
            if isSelectedFoodItem == true {
                deleteImage.image = UIImage(named: "tickmark")
                deleteButton.isHidden = true
            }
            else {
                deleteImage.image = UIImage(named: "delete")
                deleteButton.isHidden = false
            }
        }
    }
   
    var foodItem: TTFoodItem! {
        didSet {
            foodCellView.layer.cornerRadius = 5
            foodNameLabel.text = foodItem.name
            deleteButton.isHidden = true
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
    
    @IBAction func onDeleteButtonClick(_ sender: Any) {
        delegate?.deleteFoodItem(aFoodItem: foodItem)
    }
    func deleteOrSelect(isSelected: Bool) {
        if isSelected {
            deleteImage.image = UIImage(named: "tickmark")
            deleteButton.isHidden = true
        }
        else {
            deleteImage.image = UIImage(named: "delete")
            deleteButton.isHidden = false
        }
    }
    
}
