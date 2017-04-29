//
//  TTSettingsTableViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTSettingsTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var profiles: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfiles()
    }
    
    func loadProfiles() {
        let addProfileCell = TTProfile(dictionary: ["name": "Add Profile"])
        if TTUser.currentUser == nil {
            self.profiles.add(addProfileCell)
            collectionView.reloadData()
            return
        }
        TTUser.currentUser?.getProfiles(success: { (aProfiles: [TTProfile]) in
            self.profiles.addObjects(from: aProfiles)
            self.profiles.add(addProfileCell)
            
        }, failure: { (error: NSError) -> ()  in
            
            
        })
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath as IndexPath) as! TTProfileCollectionViewCell
        
        cell.setUI(aProfile: profiles[indexPath.row] as! TTProfile)
        
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onLogoutClick(_ sender: Any) {
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
