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
    
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedFoodString: String!
    var selectedFoodNSDictionary = [NSDictionary]()
    var totalPointsEarned = 0
    var foodKeyArray:[String]!
    var foodValueArray:[TTFoodItem]!
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        
        for food in foodValueArray {
            selectedFoodNSDictionary.append(food.dictionary!)
        }
        TTProfile.currentProfile?.updateFoodItems(items: selectedFoodNSDictionary, images: [], earnedPoints: totalPointsEarned, success: {
            
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
        
        navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        foodKeyArray = Array(TTFoodItem.voiceSelectedFoodItems.keys)
        foodValueArray = Array(TTFoodItem.voiceSelectedFoodItems.values)
        
        for food in foodValueArray {
            totalPointsEarned = totalPointsEarned + (food.points ?? 0)
        }
        
        collectionView.reloadData()
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
        return TTFoodItem.voiceSelectedFoodItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceCollectionCell", for: indexPath) as! VoiceCollectionViewCell
        let foodInCell = foodValueArray[indexPath.row]
        cell.foodItem = foodInCell
        
        return cell
    }
}
