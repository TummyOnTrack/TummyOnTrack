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
                foodImageView.sd_setImage(with: imageurlstring)
            }
            pointsLabel.text = "\(foodItem.points ?? 0)" + " points"
            if foodItem.points! <= 0 {
                smileyImageView.image = UIImage(named: "OMG_Face_Emoji")
            }
            else {
                smileyImageView.image = UIImage(named: "Slightly_Smiling")
            }
            shakeView()
            
        }
    }
    
    func shakeView(){
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 1
        shake.repeatCount = 10
        shake.autoreverses = true
        
        let from_point = CGPoint(x: foodImageView.center.x - 5, y: foodImageView.center.y)  //
        let from_value = NSValue(cgPoint:from_point)
        
        let to_point:CGPoint = CGPoint(x:foodImageView.center.x + 5,y: foodImageView.center.y)
        let to_value:NSValue = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        foodImageView.layer.add(shake, forKey: "position")
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
