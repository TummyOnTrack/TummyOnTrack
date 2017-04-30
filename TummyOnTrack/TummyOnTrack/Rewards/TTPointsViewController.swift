//
//  TTPointsViewController.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import AFNetworking

class TTPointsViewController: UIViewController {

    @IBOutlet weak var pointsTodayLabel: UILabel!
    @IBOutlet weak var achievementImageView: UIImageView!
    @IBOutlet weak var awesomeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let unusedPoints = TTProfile.currentProfile == nil ? 0 : TTProfile.currentProfile?.unusedPoints

        pointsTodayLabel.text = "You have \(String(describing: unusedPoints!)) points today"

        let achievementUrl = URL(string: "https://media.giphy.com/media/peAFQfg7Ol6IE/giphy.gif")
        if let achievementUrl = achievementUrl {
            achievementImageView.setImageWith(achievementUrl)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPointsHistoryButton(_ sender: Any) {
    }

    @IBAction func onDecorateMyRoomButton(_ sender: Any) {
    }
}
