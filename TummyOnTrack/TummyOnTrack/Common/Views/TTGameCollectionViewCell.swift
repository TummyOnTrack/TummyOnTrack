//
//  TTGameCollectionViewCell.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTGameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    
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
