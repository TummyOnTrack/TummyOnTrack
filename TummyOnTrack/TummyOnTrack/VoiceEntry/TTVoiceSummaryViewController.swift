//
//  TTVoiceSummaryViewController.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTVoiceSummaryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedFoodString: String!
    var defaultFoodNames = [String]()
    var selectedFoodItems = [TTFoodItem]()
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        
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
                        return true
                    }
                    else {
                        return false
                    }
                })
            }
        }
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
