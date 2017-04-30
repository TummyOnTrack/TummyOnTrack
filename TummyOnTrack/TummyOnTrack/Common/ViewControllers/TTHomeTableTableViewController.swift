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
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    var pieLayer : PieLayer! = nil
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load default food items
        loadFoodItems()

        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/4)
        pieLayer.maxRadius = Float(pieView.frame.width/2)
        
        view.layer.addSublayer(pieLayer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentProfileDetails()
    }
    
    func loadFoodItems() {
        TTFoodItem.getFoodItems(success: { () in
            //self.pieView.reloadInputViews()
        }, failure: { (error: Error) -> ()  in
            print("Failed to load food items")
        })
    }

    func setCurrentProfileDetails() {
        if TTProfile.currentProfile != nil {
            populateProfileInfo()
        }
        else {
            TTFirebaseClient.initializeCurrentProfile(success: { (aProfile: TTProfile) in
                if TTProfile.currentProfile != nil {
                    self.populateProfileInfo()
                }
                else {
                    // What to show when no profiles?
                }
            }, failure: { (error: NSError) -> ()  in
            })
        }
    }
    
    func populateProfileInfo() {
        let currentProfile_ = TTProfile.currentProfile
        self.navigationItem.title = "Hi " + (currentProfile_?.name)! + "!"
        self.profileImageView.setImageWith((currentProfile_?.profileImageURL)!)

        var pieColor = UIColor.init(red: 244/255.0, green: 115/255.0, blue: 0/255.0, alpha: 1)
        if currentProfile_?.unusedPoints == nil {
            goalHeaderLabel.text = "Eat healthy, collect points!"
            pointsLabel.text = "Your weekly points will appear here"
            pieColor = UIColor.lightGray
        }

        if pieLayer.values != nil && pieLayer.values.count == 2 {
            pieLayer.deleteValues([pieLayer.values[0], pieLayer.values[1]], animated: true)
        }
        pieLayer.addValues([PieElement(value: 5.0, color: pieColor),
                            PieElement(value: 5.0, color: UIColor.lightGray)], animated: true)
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
