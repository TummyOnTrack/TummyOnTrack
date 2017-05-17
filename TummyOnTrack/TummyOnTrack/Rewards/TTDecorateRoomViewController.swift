//
//  TTDecorateRoomViewController.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 5/3/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import AVFoundation

class TTDecorateRoomViewController: UIViewController {

    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!

    fileprivate var trayDownOffset: CGFloat!
    fileprivate var trayUp: CGPoint!
    fileprivate var trayDown: CGPoint!
    fileprivate var trayOriginalCenter: CGPoint!
    fileprivate var originalRewardCenter: CGPoint!
    fileprivate var newlyCreatedReward: UIImageView!
    fileprivate var newlyCreatedRewardCenter: CGPoint!
    
    let animationRunner = AnimationRunner()

    override func viewDidLoad() {
        super.viewDidLoad()

        trayOriginalCenter = trayView.center
        trayDownOffset = 120
        trayUp = trayOriginalCenter
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y - trayDownOffset)
        trayView.layer.cornerRadius = 3
    }

    override func viewDidAppear(_ animated: Bool) {
        loadRewards()
    }

    func loadRewards() -> Void {
        if let myRewards = TTProfile.currentProfile?.rewards {
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
        if sender.state == .ended {
            
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

        if sender.state == .began {
            animationRunner.playMusic(resourceString: "flick", resourceType: "mp3")
            originalRewardCenter = originalRewardImageView.center

            if point.y > self.trayView.frame.origin.y {
                // Pan gesture on reward in the tray, create a copy to move
                newlyCreatedReward = UIImageView(image: originalRewardImageView.image)
                view.addSubview(newlyCreatedReward)
                newlyCreatedReward.center = originalRewardCenter
                newlyCreatedReward.center.y += trayView.frame.origin.y

                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanReward(sender:)))
                let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchReward(sender:)))

                // Attach it to the reward's image view and enable user interaction
                newlyCreatedReward.isUserInteractionEnabled = true
                newlyCreatedReward.addGestureRecognizer(panGestureRecognizer)
                newlyCreatedReward.addGestureRecognizer(pinchGestureRecognizer)

                pinchGestureRecognizer.delegate = self;

                sender.view?.isHidden = true
            } else {
                // Pan gesture began outside the tray, move original
                newlyCreatedReward = originalRewardImageView
            }
        } else if sender.state == .changed {
            newlyCreatedReward.center = point
        } else if sender.state == .ended {
            if point.y > self.trayView.frame.origin.y {
                // Pan gesture ended inside the tray, return the image view to it's original location
                UIView.animate(withDuration: 0.7) {
                    originalRewardImageView.center = self.originalRewardCenter
                    if self.newlyCreatedReward != originalRewardImageView {
                        // Remove the newly created view
                        self.newlyCreatedReward.removeFromSuperview()
                        sender.view?.isHidden = false
                    }
                }
            }
        }
    }

    func didPinchReward(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        let rewardImageView = sender.view as! UIImageView
        rewardImageView.transform = rewardImageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
