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
    
    var profile: TTProfile!
    
    func setUI(aProfile: TTProfile) {
        profile = aProfile
        profileName.text = aProfile.name
        profilePhotoImageView.layer.cornerRadius = 3.5
        /*if TTProfile.currentProfile?.name == aProfile.name {
            isSelected = true
        }
        else {
            isSelected = false
        }*/
        if aProfile.profileImageURL != nil {
            profilePhotoImageView.setImageWith(aProfile.profileImageURL!)
        }
        else {
            profilePhotoImageView.image = UIImage(named: "plus-simple-7")
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.yellow : UIColor.white
        }
    }
}
