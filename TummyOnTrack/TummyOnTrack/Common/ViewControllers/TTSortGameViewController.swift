//
//  TTSortGameViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/13/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import SDWebImage

class TTSortGameViewController: UIViewController {

    @IBOutlet weak var breakfastView: UIView!
    @IBOutlet weak var lunchView: UIView!
    
    @IBOutlet weak var dinnerView: UIView!
    
    var foodItems: [TTFoodItem]?
    
    let animationRunner = AnimationRunner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        breakfastView.layer.cornerRadius = breakfastView.frame.height/2
        lunchView.layer.cornerRadius = breakfastView.frame.height/2
        dinnerView.layer.cornerRadius = breakfastView.frame.height/2
        
        for i in 0...((foodItems?.count)!-1) {
            let foodItem_ = foodItems?[i]
            renderFoodItem(aFoodItem: foodItem_!)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationRunner.playMusic(resourceString: "sort_food", resourceType: "wav")
    }
    
    func renderFoodItem(aFoodItem: TTFoodItem) {
        if let imageurlstring = aFoodItem.images?[0] {
            let randomX = Int(arc4random_uniform(UInt32(view.frame.width-100)))
            let randomY = Int(arc4random_uniform(UInt32(100)))
            let uiImageView_ = UIImageView(frame: CGRect(x: randomX, y: randomY, width: 70, height: 70))
            uiImageView_.isUserInteractionEnabled = true
            let myPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(myPanAction))
            
            myPanGestureRecognizer.minimumNumberOfTouches = 1
            myPanGestureRecognizer.maximumNumberOfTouches = 1
            
            uiImageView_.addGestureRecognizer(myPanGestureRecognizer)
            uiImageView_.sd_setImage(with: imageurlstring)
            view.addSubview(uiImageView_)
        }
        
    }
    
    func myPanAction(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            animationRunner.playMusic(resourceString: "bubble", resourceType: "mp3")
        }
        else if ((recognizer.state != UIGestureRecognizerState.ended) &&
            (recognizer.state != UIGestureRecognizerState.failed)) {
            recognizer.view?.center = recognizer.location(in: recognizer.view?.superview)
        }
        else {
            animationRunner.playMusic(resourceString: "ping", resourceType: "mp3")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
