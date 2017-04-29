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

    var profile: TTProfile!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentProfile = TTProfile.currentProfile {
            profile = currentProfile
        } else {
            print("Create fake profile for now")
            var fakeProfile = [String: Any?]()
            fakeProfile["name"] = "Emily"
            fakeProfile["age"]  = 6
            fakeProfile["isParent"] = false
            fakeProfile["unusedPoints"] = 20
            fakeProfile["totalPoints"] = 200
            fakeProfile["goalPoints"] = 40
            fakeProfile["user_name"] = TTUser.currentUser?.username

            profile = TTProfile(dictionary: fakeProfile as NSDictionary)
        }

        pointsTodayLabel.text = "You have \(String(describing: profile.unusedPoints!)) points today"

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
