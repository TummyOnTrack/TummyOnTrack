//
//  TTProfileCollectionViewCell.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/29/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//
import UIKit

class TTProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var profile: TTProfile! {
        didSet {
//            self.contentView.backgroundColor = isSelected ? UIColor.yellow : UIColor.white
            
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            profileName.textColor = .white
            profilePhotoImageView.layer.cornerRadius = 3.5
            
            if let name = profile.name {
                profileName.text = name
            }
            
            if let imageUrl = profile.profileImageURL {
                profilePhotoImageView.setImageWith(imageUrl)
            }
            
        }
    }
    
//    func setUI(aProfile: TTProfile) {
//        profile = aProfile
//        profileName.text = aProfile.name
//        profilePhotoImageView.layer.cornerRadius = 3.5
//        /*if TTProfile.currentProfile?.name == aProfile.name {
//            isSelected = true
//        }
//        else {
//            isSelected = false
//        }*/
//        if aProfile.profileImageURL != nil {
//            profilePhotoImageView.setImageWith(aProfile.profileImageURL!)
//        }
//        else {
//            profilePhotoImageView.image = UIImage(named: "plus-simple-7")
//        }
//    }
    
  
}
