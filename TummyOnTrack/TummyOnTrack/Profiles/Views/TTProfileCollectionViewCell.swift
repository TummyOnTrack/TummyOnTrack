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
    @IBOutlet weak var star: UIImageView!
    
    
    var profile: TTProfile! {
        didSet {
//            setUI()
//            self.contentView.backgroundColor = isSelected ? UIColor.orange : UIColor.white

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
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.orange : UIColor.white
        }
    }
    
//    func setUI() {
//
//        if TTProfile.currentProfile?.name == profile.name {
//            isSelected = true
//        }
//        else {
//            isSelected = false
//        }
//    }
    
  
}
