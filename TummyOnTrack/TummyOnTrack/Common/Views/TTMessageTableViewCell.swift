//
//  TTMessageTableViewCell.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/12/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var faceImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
