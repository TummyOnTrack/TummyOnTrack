//
//  TTHomeTableTableViewController.swift
//  TummyOnTrack
//
//
//  //  <div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a></div>
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import MagicPie
import Firebase

class TTHomeTableTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var setupGoalButton: UIButton!
    @IBOutlet weak var goalPointsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    var pieLayer : PieLayer! = nil
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var monButton: UIButton!
    
    @IBOutlet weak var satButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var thursButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var tuesButton: UIButton!
    @IBOutlet weak var sunButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load default food items
        loadFoodItems()
        
        setToday()

        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/3)
        pieLayer.maxRadius = Float(pieView.frame.width/2)
        
        view.layer.addSublayer(pieLayer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentProfileDetails()
    }
    
    func setToday() {
        let date = Date()
        let calendar = Calendar.current
        
        //let year = calendar.component(.year, from: date)
        //let month = calendar.component(.month, from: date)
        //TODO: Bad logic. Fix it.
        let day = calendar.component(.weekday, from: date)
        if day == 1 {
            setButtonColor(aButton: sunButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: sunButton, aColor: UIColor.black)
        }
        if day == 2 {
            setButtonColor(aButton: monButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: monButton, aColor: UIColor.black)
        }
        if day == 3 {
            setButtonColor(aButton: tuesButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: tuesButton, aColor: UIColor.black)
        }
        if day == 4 {
            setButtonColor(aButton: wedButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: wedButton, aColor: UIColor.black)
        }
        if day == 5 {
            setButtonColor(aButton: thursButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: thursButton, aColor: UIColor.black)
        }
        if day == 6 {
            setButtonColor(aButton: friButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: friButton, aColor: UIColor.black)
        }
        if day == 7 {
            setButtonColor(aButton: satButton, aColor: UIColor.red)
        }
        else {
            setButtonColor(aButton: satButton, aColor: UIColor.black)
        }
        
        print(day)
    }
    
    func setButtonColor( aButton: UIButton, aColor: UIColor) {
        aButton.setTitleColor(aColor, for: UIControlState.normal)
    }
    
    func loadFoodItems() {
        TTFoodItem.getFoodItems(success: { () in
            //self.pieView.reloadInputViews()
        }, failure: { (error: Error) -> ()  in
            print("Failed to load food items")
        })
    }
    @IBAction func onSetupGoalClick(_ sender: Any) {
        
    }

    func setCurrentProfileDetails() {
        if TTProfile.currentProfile != nil {
            populateProfileInfo()
        }
    }
    
    func populateProfileInfo() {
        let currentProfile_ = TTProfile.currentProfile
        self.navigationItem.title = "Hi " + (currentProfile_?.name)! + "!"
        self.profileImageView.setImageWith((currentProfile_?.profileImageURL)!)
        setupGoalButton.isHidden = true
        var pieColor = UIColor.init(red: 244/255.0, green: 115/255.0, blue: 0/255.0, alpha: 1)
        if currentProfile_?.weeklyEarnedPoints == 0 && currentProfile_?.goalPoints == 0 {
            goalHeaderLabel.text = "Eat healthy, collect points!"
            pointsLabel.text = "Your weekly points will appear here"
            goalPointsLabel.text = "Setup Weekly Goal"
            setupGoalButton.isHidden = false
            pieColor = UIColor.lightGray
        }
        else {
            goalPointsLabel.text = "Goal: " + "\((currentProfile_?.goalPoints)!)" + "Pts"
        }
        if pieLayer.values != nil && pieLayer.values.count == 2 {
            pieLayer.deleteValues([pieLayer.values[0], pieLayer.values[1]], animated: true)
        }
        let greyPoints = Float((currentProfile_?.goalPoints)! - (currentProfile_?.weeklyEarnedPoints)!)
        
        pieLayer.addValues([PieElement(value: Float((currentProfile_?.weeklyEarnedPoints)!), color: pieColor),
                            PieElement(value: greyPoints, color: UIColor.lightGray)], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCameraClick(_ sender: Any) {
       
        
        let alertController =  UIAlertController()
        let  takePhotoButton = UIAlertAction(title: "Take Photo", style: .destructive, handler: { (action) -> Void in
            
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            
            self.present(self.imagePicker, animated: true, completion: nil)
            
        })
        
        let galleryButton = UIAlertAction(title: "Choose From Photos", style: .cancel, handler: { (action) -> Void in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        
        alertController.addAction(takePhotoButton)
        alertController.addAction(galleryButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let viewController = UIStoryboard(name: "CommonStoryboard", bundle: nil).instantiateViewController(withIdentifier: "AddPhotoView") as? TTAddPhotoTableViewController {
            viewController.photoImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            present(viewController, animated: true, completion: nil)
        }
    }
}
