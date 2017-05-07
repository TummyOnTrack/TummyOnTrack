//
//  TTFillPlateTableCell.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/6/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import SDWebImage

class TTFillPlateTableCell: UITableViewCell {

    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var smileyImageView: UIImageView!
    @IBOutlet weak var foodImageView: UIImageView!
    
    @IBOutlet weak var pointsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var foodItem: TTFoodItem! {
        didSet {
            foodNameLabel.text = foodItem.name
            if let imageurlstring = foodItem.images?[0] {
                /*if let data = try? Data(contentsOf: imageurlstring) {
                    foodImageView.image = UIImage(data: data)
                }*/
                foodImageView.sd_setImage(with: imageurlstring)
            }
            pointsLabel.text = "\(foodItem.points ?? 0)" + " points"
            if foodItem.points! <= 0 {
                smileyImageView.image = UIImage(named: "OMG_Face_Emoji")
            }
            else {
                smileyImageView.image = UIImage(named: "Slightly_Smiling")
            }
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
