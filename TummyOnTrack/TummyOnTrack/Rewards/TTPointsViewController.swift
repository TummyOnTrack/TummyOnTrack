//
//  TTPointsViewController.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import AFNetworking
import AVFoundation

class TTPointsViewController: UIViewController {

    @IBOutlet weak var pointsTodayLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var awesomeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var decorateButton: UIButton!
    fileprivate var bubbleSound: SystemSoundID!

    fileprivate let awesomeSynonyms = [ "Awesome", "Excellent", "Great", "Incredible", "Marvelous", "Unbelievable", "Wonderful"]

    override func viewDidLoad() {
        super.viewDidLoad()
        bubbleSound = createBubbleSound()
        animateButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateProfile()
        animateAchievement()
    }

    func populateProfile() {
        let unusedPoints = TTProfile.currentProfile?.unusedPoints

        if unusedPoints == 0 {
            pointsTodayLabel.text = "Eat healthy, collect points!"
            awesomeLabel.isHidden = true
        } else {
            pointsTodayLabel.text = "\(String(describing: unusedPoints!)) unused points!"
            let randomIndex = Int(arc4random_uniform(UInt32(awesomeSynonyms.count)))
            awesomeLabel.text = "\(awesomeSynonyms[randomIndex])!"
            awesomeLabel.isHidden = false
        }

        pointsTodayLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        if let currentProfile = TTProfile.currentProfile {
            profileNameLabel.text = currentProfile.name?.capitalized
            profileNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            if let profileImageURL = currentProfile.profileImageURL {
                profileImageView.setImageWith(profileImageURL)
                profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            }
        }
    }

    func animateAchievement() {
        for _ in 0...5 {
            // create a square image view
            let square = UIImageView()
            square.frame = CGRect(x: 55, y: 300, width: 32, height: 32)
            // Add image to the square
            square.image = UIImage(named: "carrot")
            self.view.addSubview(square)

            // randomly create a value between 0.0 and 150.0
            let randomYOffset = CGFloat( arc4random_uniform(150))

            // for every y-value on the bezier curve
            // add our random y offset so that each individual animation
            // will appear at a different y-position
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 16,y: 80 + randomYOffset))
            path.addCurve(to: CGPoint(x: 375, y: 80 + randomYOffset), controlPoint1: CGPoint(x: 136, y: 220 + randomYOffset), controlPoint2: CGPoint(x: 178, y: 30 + randomYOffset))

            // create the animation
            let anim = CAKeyframeAnimation(keyPath: "position")
            anim.path = path.cgPath
            anim.rotationMode = kCAAnimationRotateAuto
            anim.repeatCount = Float.infinity
            anim.duration = 5.0

            // each square will take between 4.0 and 8.0 seconds
            // to complete one animation loop
            anim.duration = Double(arc4random_uniform(40)+30) / 10

            // stagger each animation by a random value
            // `290` was chosen simply by experimentation
            anim.timeOffset = Double(arc4random_uniform(290))

            // add the animation
            square.layer.add(anim, forKey: "animate position along path")
        }
    }

    func animateButton() {
        AudioServicesPlaySystemSound(bubbleSound)
        shopButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        decorateButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: 2,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.shopButton.transform = .identity
                        self.decorateButton.transform = .identity
        }, completion: { finished in
                        self.animateButton()
        })
    }

    func createBubbleSound() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "bubble" as CFString!, "mp3" as CFString!, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
