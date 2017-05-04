//
//  TTProfilesViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//
import UIKit
import Firebase
import SVProgressHUD

class TTProfilesViewController: UITableViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addProfilesLabel: UILabel!
    var profiles = [TTProfile]()


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllProfiles()
    }

    func getAllProfiles() {
        SVProgressHUD.show()
        
        TTUser.currentUser?.getProfiles(success: { (profiles) in
            SVProgressHUD.dismiss()
            self.profiles = profiles
            self.collectionView.reloadData()
        }, failure: { (error) in
            print(error)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    @IBAction func logoutUser(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        UserDefaults.standard.removeObject(forKey: "email")
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let onboardingRootController = onboardingStoryboard.instantiateViewController(withIdentifier: "SignupLoginViewController")
        let navController = UINavigationController(rootViewController: onboardingRootController)
        self.present(navController, animated: true, completion: nil)
    }
  
}

extension TTProfilesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count + 1
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMemberCell", for: indexPath)
            cell.layer.cornerRadius = 3.5
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! TTProfileCollectionViewCell
        cell.layer.cornerRadius = 3.5
        cell.profile = profiles[indexPath.row - 1]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            /*let commonStoryboard = UIStoryboard(name: "CommonStoryboard", bundle: nil)
            let homeVc = commonStoryboard.instantiateViewController(withIdentifier: "HomeView") as! TTHomeTableTableViewController
            homeVc.homeViewProfile = self.profiles[indexPath.row - 1]
            self.navigationController?.pushViewController(homeVc, animated: true)*/
            TTProfile.currentProfile = self.profiles[indexPath.row-1]
            tabBarController?.selectedIndex = 0

        }

    }

}
