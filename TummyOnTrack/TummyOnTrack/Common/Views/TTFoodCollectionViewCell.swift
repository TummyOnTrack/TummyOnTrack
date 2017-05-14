//
//  TTFoodCollectionViewCell.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/13/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTFoodCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var smileyImageView: UIImageView!
    var animate: Bool = false
    
    var foodItem: TTFoodItem! {
        didSet {
            foodNameLabel.text = foodItem.name
            if let imageurlstring = foodItem.images?[0] {
                foodImageView.sd_setImage(with: imageurlstring)
            }
            pointsLabel.text = "\(foodItem.points ?? 0)"
            if foodItem.points! <= 0 {
                smileyImageView.image = UIImage(named: "OMG_Face_Emoji")
            }
            else {
                smileyImageView.image = UIImage(named: "Slightly_Smiling")
            }
            if animate == true {
                shakeView()
                rotateSmiley()
            }
            
        }
    }
    
    func shakeView(){
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.3
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point = CGPoint(x: foodImageView.center.x - 5, y: foodImageView.center.y)  //
        let from_value = NSValue(cgPoint:from_point)
        
        let to_point:CGPoint = CGPoint(x:foodImageView.center.x + 5,y: foodImageView.center.y)
        let to_value:NSValue = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        foodImageView.layer.add(shake, forKey: "position")
    }
    
    func rotateSmiley(){
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi
        rotationAnimation.duration = 0.3
        rotationAnimation.repeatCount = 2
        
        smileyImageView.layer.add(rotationAnimation, forKey: nil)
    }

}
