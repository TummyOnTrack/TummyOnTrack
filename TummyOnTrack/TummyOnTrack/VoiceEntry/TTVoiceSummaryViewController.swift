//
//  TTVoiceSummaryViewController.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTVoiceSummaryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VoiceCollectionCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var selectedFoodString: String!
    var selectedFoodNSDictionary = [NSDictionary]()
    var totalPointsEarned = 0
    var foodKeyArray:[String]!
    var foodValueArray:[TTFoodItem]!
    var selectedBoolArray = [Bool]()
    var animateOnLongPress = true
    let animationRunner = AnimationRunner()
    
    @IBAction func doneBarButton(_ sender: UIBarButtonItem) {
        
        for (index, food) in foodValueArray.enumerated() {
            if selectedBoolArray[index] {
                selectedFoodNSDictionary.append(food.dictionary!)
            }
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
            selectedBoolArray.append(true)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 25.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VoiceSummaryHeader", for: indexPath) as! VoiceSummaryHeader
        headerView.points = totalPointsEarned
        return headerView
    }
    
    func  onLongPressed(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if animateOnLongPress == true {
            animateOnLongPress = false
            let location = longPressGestureRecognizer.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: location)
            let cell = self.collectionView.cellForItem(at: indexPath!) as! VoiceCollectionViewCell
            let originalTransform = cell.foodImageView.transform
            UIView.animate(withDuration: 2.0, animations: {
                self.animationRunner.playMusic(resourceString: "bubble", resourceType: "mp3")
                cell.foodImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.foodImageView.transform = originalTransform
            }, completion: { (value:Bool) in
                self.animateOnLongPress = true
            })
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedBoolArray[indexPath.row] == true {
            //make it deleted
            selectedBoolArray[indexPath.row] = false
            
            totalPointsEarned = totalPointsEarned - foodValueArray[indexPath.row].points!
            
        }
        else {
            //make selected
            selectedBoolArray[indexPath.row] = true
            totalPointsEarned = totalPointsEarned + foodValueArray[indexPath.row].points!
        }
        
        self.collectionView.reloadSections(IndexSet(integer: 0))

    }
    
    func deleteFoodItem( aFoodItem: TTFoodItem) {
        for i in 0...foodValueArray.count-1 {
            let iFood = foodValueArray[i]
            if iFood.name == aFoodItem.name {
                foodValueArray.remove(at: i)
                break;
            }
        }
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodValueArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceCollectionCell", for: indexPath) as! VoiceCollectionViewCell
        let foodInCell = foodValueArray[indexPath.row]
        let press = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed(longPressGestureRecognizer:)))
        cell.delegate = self
        cell.foodItem = foodInCell
        cell.isSelectedFoodItem = selectedBoolArray[indexPath.row]
        cell.foodCellView.addGestureRecognizer(press)
        
        return cell
    }
}
