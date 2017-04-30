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
    
    @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    var pieLayer : PieLayer! = nil
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load default food items
        let ref = FIRDatabase.database().reference(fromURL: "https://tummyontrack.firebaseio.com/").child("FoodItem")
        let query = ref.queryOrdered(byChild: "name")
        query.observeSingleEvent(of: .value, with: { snapshot in
            
            for snap in snapshot.children {
                let snap_ = snap as! FIRDataSnapshot
                let dict = snap_.value as! NSDictionary
                let newFood = TTFoodItem(dictionary: dict)
                if (TTFoodItem.defaultFoodList?.append(newFood)) == nil {
                    TTFoodItem.defaultFoodList = [newFood]
                }
            }
        })
        
        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/4)
        pieLayer.maxRadius = Float(pieView.frame.width/2)
        
        view.layer.addSublayer(pieLayer)
        
        if pieLayer.values != nil && pieLayer.values.count == 2 {
            pieLayer.deleteValues([pieLayer.values[0], pieLayer.values[1]], animated: true)
        }
        pieLayer.addValues([PieElement(value: 5.0, color: UIColor.init(red: 244/255.0, green: 115/255.0, blue: 0/255.0, alpha: 1)),
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
