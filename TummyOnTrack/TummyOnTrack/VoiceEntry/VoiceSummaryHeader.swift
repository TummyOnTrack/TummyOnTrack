//
//  VoiceSummaryHeader.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 5/4/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class VoiceSummaryHeader: UICollectionReusableView {
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    var points: Int {
        get {
            return self.points
        }
        set(newValue) {
            totalPointsLabel.text = "You have scored \(newValue) points!"
        }
    }
}
