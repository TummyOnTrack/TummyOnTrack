//
//  TTDecorateRoomViewController.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 5/3/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTDecorateRoomViewController: UIViewController {

    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!

    fileprivate var trayDownOffset: CGFloat!
    fileprivate var trayUp: CGPoint!
    fileprivate var trayDown: CGPoint!
    fileprivate var trayOriginalCenter: CGPoint!
    fileprivate var myRewards: [TTReward]?

    override func viewDidLoad() {
        super.viewDidLoad()

        trayDownOffset = 120
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y - trayDownOffset)

        myRewards = TTProfile.currentProfile?.rewards

        loadRewards()
    }

    func loadRewards() -> Void {
        if let myRewards = myRewards {
            var x = 0, y = 30
            let xOffset = 55, yOffset = 55

            for myReward in myRewards {
                let frame = CGRect(x: x, y: y, width: 50, height: 50)
                let imageView = UIImageView(frame: frame)
                imageView.setImageWith(myReward.thumbnailURL!)
                imageView.isUserInteractionEnabled = true

                trayView.addSubview(imageView)
                x += xOffset

                // If the next image's right edge will be past the frame
                // start a new row of images
                if x + xOffset > Int(trayView.frame.width) {
                    x = 0
                    y += yOffset
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPanTray(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            trayOriginalCenter = trayView.center
        } else if sender.state == .changed {

        } else if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayUp
                    self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                })
            } else {
                // Animation with bounce effect
                UIView.animate(withDuration:0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayDown
                                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                }, completion: nil)
            }
        }
    }
}
