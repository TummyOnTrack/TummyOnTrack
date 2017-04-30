//
//  TTSettingsTableViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTSettingsTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var profiles: NSMutableArray = []
    
    var selectedProfile: TTProfile?
    
    @IBOutlet weak var addProfilesLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = false
        loadProfiles()
    }
    
    func loadProfiles() {
        let addProfileCell = TTProfile(dictionary: ["name": "Add Member"])
        
        TTUser.currentUser?.getProfiles(success: { (aProfiles: [TTProfile]) in
            self.profiles.addObjects(from: aProfiles)
            if self.profiles.count == 0 {
                self.addProfilesLabel.text = "Create a family member's profile"
            }
            else {
                self.addProfilesLabel.text = "Change current member"
            }
            self.profiles.add(addProfileCell)
            self.collectionView.reloadData()
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == profiles.count - 1 {
            TTUser.currentUser?.addProfile(aProfile: profiles[indexPath.row] as! TTProfile)
        }
        else {
           // TTUser.currentUser?.changeCurrentProfile(aProfile: profiles[indexPath.row] as! TTProfile)
            selectedProfile = profiles[indexPath.row] as? TTProfile
        }
    }
    
    @IBAction func onChangeProfileClick(_ sender: Any) {
        TTUser.currentUser?.changeCurrentProfile(aProfile: selectedProfile!)
        tabBarController?.selectedIndex = 0
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
