//
//  AddTTProfileViewController.swift
//  TummyOnTrack
//
//  Created by yanze on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SystemConfiguration
import Firebase
import FirebaseStorage
import SVProgressHUD

class AddTTProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var ageTextfield: UITextField!
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImgView.layer.cornerRadius = 3.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addProfileClicked(_ sender: Any) {
        guard let name = namefield.text else {
            print("Name cannot be empty")
            return
        }
        guard let age = ageTextfield.text else {
            print("Age cannot be empty")
            return
        }
        guard let image = profileImgView.image else {
            print("profile image when adding member")
            return
        }
        SVProgressHUD.show()
        TTUser.currentUser?.addProfile(name: name, age: Int(age)!, image: image, completionHandler: { (status) in
            SVProgressHUD.dismiss()
            if status {
                //self.navigationController?.popViewController(animated: true)
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "MainPageTabBarController") as! UITabBarController
                self.present(homeVC, animated: true, completion: nil)
            }
        })
    }



    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func uploadProfileImageClicked(_ sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController()
        self.imagePicker.delegate = self
        let choose = UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.default) {(ACTION) in
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                self.accessPhotoLibrary()
            case .denied:
                self.redirectAlertDialog(type: "choosePhoto")
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization() { status in
                    switch status {
                    case .authorized:
                        self.accessPhotoLibrary()
                    case .denied:
                        self.redirectAlertDialog(type: "choosePhoto")
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
        let take = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default) {(ACTION) in
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if authStatus == AVAuthorizationStatus.authorized {
                self.accessCamera()
            }
            else if authStatus == AVAuthorizationStatus.denied {
                self.redirectAlertDialog(type: "cameraAccess")
                
            }
            else if authStatus == AVAuthorizationStatus.notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                    if granted {
                        self.accessCamera()
                    }
                    else {
                        // show an alert ,if user click cancle, then redirect to homeVC
                        self.redirectAlertDialog(type: "cameraAccess")
                    }
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {(ACTION) in}
        actionSheet.addAction(choose)
        actionSheet.addAction(take)
        actionSheet.addAction(cancel)
        // block below is for iPad
        if actionSheet.popoverPresentationController != nil {
            actionSheet.popoverPresentationController!.sourceView = self.view
            actionSheet.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection.up
            actionSheet.popoverPresentationController!.sourceRect = CGRect(x:self.view.frame.size.width/2, y:135, width:1.0, height:1.0)
        }
        self.present(actionSheet, animated: true, completion: nil)
        
    }

}

extension AddTTProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profileImgView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func redirectAlertDialog(type: String) {
        var title = ""
        var message = ""
        if type == "choosePhoto" {
            title = "Access Photo Library"
            message = "Allow access to your photo library to start choosing photos with the Every Moment app."
        }
        else {
            title = "Access Camera"
            message = "Allow access to your camera to start taking photos with the Every Moment app."
        }
        // add un alert
        let redirectingDialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        redirectingDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{(action: UIAlertAction!) in
            
        }))
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        redirectingDialog.addAction(UIAlertAction(title: "Settings", style: .default, handler:{(action: UIAlertAction!) in
            // go to system settings page
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }))
        self.present(redirectingDialog, animated: true, completion: nil)
    }
    
    fileprivate func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        }

        self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        DispatchQueue.main.async(execute: {            
           self.present(self.imagePicker, animated: true, completion: nil)
        })
        
    }
    
    fileprivate func accessPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker.sourceType = .photoLibrary
        }

        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: self.imagePicker.sourceType)!
        DispatchQueue.main.async(execute: {
             self.present(self.imagePicker, animated: true, completion: nil)
        })

       
    }
}
