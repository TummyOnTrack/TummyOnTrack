//
//  TTVoiceSummaryViewController.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTVoiceSummaryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBAction func speakAgainBarButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedFoodString: String!
    var defaultFoodNames = [String]()
    var selectedFoodItems = [TTFoodItem]()
    var selectedFoodNSDictionary = [NSDictionary]()
    var totalPointsEarned = 0
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        TTFoodItem.updateFoodItems(items: selectedFoodNSDictionary, images: [], earnedPoints: totalPointsEarned, success: { 
            
        }) { (error: NSError) in
            print(error.localizedDescription)
        }

//        if let currentProfileName_ = TTProfile.currentProfile?.name {
//            let ref1 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)
//            let query = ref1.queryOrdered(byChild: "name").queryEqual(toValue: currentProfileName_)
//            
//            query.observeSingleEvent(of: .value, with: { (snapshot) in
//                for snap in snapshot.children {
//                    let snap_ = snap as! FIRDataSnapshot
//                    print(snap_.key)
//                    
//                    let ref2 = FIRDatabase.database().reference(fromURL: BASE_URL).child(DAILYFOOD_TABLE).childByAutoId()
//                    let dailyEntry = ["profile": TTProfile.currentProfile?.dictionary, "items": self.selectedFoodNSDictionary, "images": [], "earnedPoints" : self.totalPointsEarned, "createdAt": Date().timeIntervalSince1970, "updatedAt": Date().timeIntervalSince1970, "profileId": snap_.key] as [String: Any]
//                    ref2.updateChildValues(dailyEntry)
//                    
//                    let ref3 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(snap_.key)")
//                    let totalUnused = self.totalPointsEarned + (TTProfile.currentProfile?.unusedPoints)!
//                    let totalWeekly = self.totalPointsEarned + (TTProfile.currentProfile?.weeklyEarnedPoints)!
//                    ref3.updateChildValues(["unusedPoints": totalUnused, "weeklyPoints": totalWeekly])
//                }
//            })
//        }
//        else {
//            print("No profile created")
//        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        checkForFoodItemsPresent()
        collectionView.reloadData()
    }
    
    func checkForFoodItemsPresent() {
        for food in TTFoodItem.defaultFoodList {
            if let name = food.name?.lowercased() {
                defaultFoodNames.append(name)
            }
        }

        if selectedFoodString != nil {
            let selectedFoodArray = selectedFoodString.components(separatedBy: " ")
            for selectedFood in selectedFoodArray {
               _ = TTFoodItem.defaultFoodList.contains(where: { (food: TTFoodItem) -> Bool in
                    if selectedFood == food.name?.lowercased() {
                        selectedFoodItems.append(food)
                        selectedFoodNSDictionary.append(food.dictionary!)
                        if let points = food.points {
                           totalPointsEarned = totalPointsEarned + points
                        }
                        return true
                    }
                    else {
                        return false
                    }
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 25.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VoiceSummaryHeader", for: indexPath) as! VoiceSummaryHeader
        headerView.totalPointsLabel.text = "You have scored \(totalPointsEarned) points!"
        return headerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoodItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceCollectionCell", for: indexPath) as! VoiceCollectionViewCell
        let foodInCell = selectedFoodItems[indexPath.row]
        cell.foodItem = foodInCell
        
        return cell
    }
}
