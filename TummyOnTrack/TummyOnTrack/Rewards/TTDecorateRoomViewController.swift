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

    fileprivate var originalRewardCenter: CGPoint!
    fileprivate var newlyCreatedReward: UIImageView!
    fileprivate var newlyCreatedRewardCenter: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()

        trayOriginalCenter = trayView.center
        trayDownOffset = 120
        trayUp = trayOriginalCenter
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y - trayDownOffset)
        trayView.layer.cornerRadius = 3

        myRewards = TTProfile.currentProfile?.rewards

        loadRewards()
    }

    func loadRewards() -> Void {
        if let myRewards = myRewards {
            var x = 0, y = 30
            let xOffset = 55, yOffset = 55

            for myReward in myRewards {
                let frame = CGRect(x: x, y: y, width: 50, height: 50)
                let myRewardImageView = UIImageView(frame: frame)
                myRewardImageView.setImageWith(myReward.thumbnailURL!)
                myRewardImageView.isUserInteractionEnabled = true

                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanReward(sender:)))
                myRewardImageView.addGestureRecognizer(panGestureRecognizer)

                trayView.addSubview(myRewardImageView)
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

extension TTDecorateRoomViewController: UIGestureRecognizerDelegate {

    func didPanReward(sender: UIPanGestureRecognizer) {
        let originalRewardImageView = sender.view as! UIImageView
        let point = sender.location(in: view)
        var imageViewToPan = originalRewardImageView
        if sender.state == .began {
            originalRewardCenter = originalRewardImageView.center

            if point.y > self.trayView.frame.origin.y {
                // Pan gesture on reward in the tray, create a copy to move
                newlyCreatedReward = UIImageView(image: originalRewardImageView.image)
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanReward(sender:)))
                let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchReward(sender:)))

                // Attach it to the reward's image view and enable user interaction
                newlyCreatedReward.isUserInteractionEnabled = true
                newlyCreatedReward.addGestureRecognizer(panGestureRecognizer)
                newlyCreatedReward.addGestureRecognizer(pinchGestureRecognizer)

                pinchGestureRecognizer.delegate = self;

                imageViewToPan = newlyCreatedReward
            } else {
                newlyCreatedReward = nil
            }
        } else if sender.state == .changed {
            let translation = sender.translation(in: view)
            UIView.animate(withDuration: 0.3, animations: {
                imageViewToPan.center = CGPoint(x: self.originalRewardCenter.x + translation.x, y: self.originalRewardCenter.y + translation.y)
            })
        } else if sender.state == .ended {
            if point.y > self.trayView.frame.origin.y {
                // Pan gesture ended inside the tray, return the image view to it's original location
                UIView.animate(withDuration: 0.7) {
                    originalRewardImageView.center = self.originalRewardCenter
                    if self.newlyCreatedReward != nil {
                        // Remove the newly created view
                        self.newlyCreatedReward.removeFromSuperview()
                    }
                }
            } else if newlyCreatedReward != nil {
                // Pan gesture ended outside the tray, add the newly created view to the superview
                newlyCreatedReward.center = originalRewardImageView.center

                // Since the original reward is in the tray, but the new reward is in the
                // main view, you have to offset the coordinates
                newlyCreatedReward.center.y += trayView.frame.origin.y

                UIView.animate(withDuration: 0.7) {
                    originalRewardImageView.center = self.originalRewardCenter
                    self.newlyCreatedReward.center = sender.location(in: self.view)
                    self.view.addSubview(self.newlyCreatedReward)
                }
            }
        }
    }

    func didPinchReward(sender: UIPinchGestureRecognizer) {
        let point = sender.location(in: view)
        print("Pinch Gesture began at: \(point)")
        let scale = sender.scale
        let rewardImageView = sender.view as! UIImageView
        rewardImageView.transform = rewardImageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
