//
//  TTAddPhotoTableViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/27/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTAddPhotoTableViewController: UITableViewController {
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    var photoImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoImageView.image = photoImage
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
