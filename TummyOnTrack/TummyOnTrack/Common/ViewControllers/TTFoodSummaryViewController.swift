//
//  TTFoodSummaryViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/13/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Speech

class TTFoodSummaryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var foodBlog: [TTDailyFoodEntry]!
    var foodItems = [TTFoodItem]()
    var sectionFoodItems : NSMutableDictionary = [:]
    var dayOfWeek: String!
    var message: String!
    var fullDayOfWeek: NSDictionary! = ["Sun": "Sunday", "Mon": "Monday", "Tues" : "Tuesday", "Wed" : "Wednesday", "Thur": "Thursday", "Fri" : "Friday", "Sat" : "Saturday"]
    
    var categoryMessage: NSDictionary! = ["Protein": "Proteins make your bones stronger!", "Carbohydrate": "Eating carbs gives you energy to run around.", "Vegetable" : "Vegetables are full of Vitamins.", "Drink" : "A glass of water is the best drink for your body", "Fruit": "Fruits are yummy and good for you", "Dairy" : "Milk and cheese are full of calcium and proteins", "Dessert" : "Good job skipping dessert today!", "Other" : "Other"]
    
    var categories : NSArray! = ["Protein", "Vegetable", "Fruit", "Carbohydrate", "Dairy", "Drink", "Dessert", "Other" ]
    
    let animationRunner = AnimationRunner()
    var utterance: AVSpeechUtterance!
    var synthesizer: AVSpeechSynthesizer!
    
    var animate : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        synthesizer = AVSpeechSynthesizer()
        
        animationRunner.playMusic(resourceString: "ping", resourceType: "mp3")
        //synthesizer.delegate = self
        message = "Fetching food entries for " + (fullDayOfWeek[dayOfWeek] as! String)
        foodItems = []
        
        navigationItem.title = (fullDayOfWeek[dayOfWeek] as! String) + "'s Food Blog"
        populateFood()
    }
    
    func populateFood() {
        
        if foodBlog.count == 0 {
            message = "Oops, No food entries for " + (fullDayOfWeek[dayOfWeek] as! String)
            enablePlayGameButton(aFlag: false)
        }
        else {
            for i in 0...(foodBlog.count - 1) {
                let blog = foodBlog[i] as TTDailyFoodEntry
                if blog.items != nil && (blog.items?.count)! > 0 {
                    for j in 0...((blog.items?.count)! - 1) {
                        let item_ = blog.items?[j]
                        foodItems.append(item_!)
                    }
                }
            }
            enablePlayGameButton(aFlag: true)
            populateSectionFoodItems()
            collectionView.reloadData()
        }
        
        
    }
    
    func enablePlayGameButton(aFlag : Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Game", style: .plain, target: self, action: #selector(gameTapped))
    }
    
    func gameTapped() {
        performSegue(withIdentifier: "Show Game Page", sender: nil)
    }
    
    func populateSectionFoodItems() {
        
        
        for i in 0...foodItems.count-1 {
            let item_ = foodItems[i] as TTFoodItem
            let tags_ = item_.tags
            if tags_ == nil {
                sectionFoodItems.setObject([item_], forKey: "Other" as NSCopying)
                continue
            }
            if (tags_?.count)! > 0 {
                var flag = false
                for j in 0...(tags_?.count)!-1 {
                    print(tags_?[j] ?? "xx")
                    if categories.contains(tags_?[j] ?? "xx") {
                        let objs_ = sectionFoodItems.object(forKey: tags_?[j] ?? "x")
                        if objs_ == nil {
                            sectionFoodItems.setObject([item_], forKey: tags_?[j] as NSCopying? ?? "x" as NSCopying)
                        }
                        else {
                            var objArr_ = objs_ as! Array<Any>
                            objArr_.append(item_)
                            sectionFoodItems.setObject(objArr_, forKey: tags_?[j] as NSCopying? ?? "x" as NSCopying)
                        }
                        flag = true
                        break
                    }
                }
                if flag == false {
                    sectionFoodItems.setObject([item_], forKey: "Other" as NSCopying)
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let objs_ = sectionFoodItems.object(forKey: categories.object(at: section))
        if objs_ == nil{
            return CGSize(width: collectionView.frame.size.width, height: 66)
        }
        return CGSize(width: collectionView.frame.size.width, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FoodTypeHeader", for: indexPath)
        var label_ = headerView.viewWithTag(1) as! UILabel
        label_.text = categories.object(at: indexPath.section) as? String
        label_ = headerView.viewWithTag(2) as! UILabel
        let img_ = headerView.viewWithTag(3) as! UIImageView
        let objs_ = sectionFoodItems.object(forKey: categories.object(at: indexPath.section))
        if objs_ == nil {
            label_.text = categoryMessage.object(forKey: categories.object(at: indexPath.section)) as? String
            img_.image = UIImage(named: "Face_With_Rolling")
        }
        else {
            label_.text = ""
            img_.image = nil
        }
        return headerView
    }
    
    
       
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(sectionFoodItems.count == 0) {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            // label.center = CGPoint(x: 160, y: 285)
            label.textAlignment = .center
            label.text = message
            label.numberOfLines = 0
            collectionView.backgroundView = label
            return 0
        }
        else {
            collectionView.backgroundView = nil
            if sectionFoodItems.object(forKey: categories.object(at: section)) == nil {
                return 0
            }
            return (sectionFoodItems.object(forKey: categories.object(at: section)) as! Array<Any>).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let objs_ = sectionFoodItems.object(forKey: categories.object(at: indexPath.section))
        
        let objArr_ = objs_ as! Array<Any>
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodSummaryCell", for: indexPath) as! TTFoodCollectionViewCell
        cell.animate = animate
        cell.foodItem = objArr_[indexPath.row] as! TTFoodItem
        return cell        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objs_ = sectionFoodItems.object(forKey: categories.object(at: indexPath.section))
        if objs_ != nil {
            let objArr_ = objs_ as! Array<Any>
            let foodItem = objArr_[indexPath.row] as! TTFoodItem
            if foodItem.joke != nil {
                animationRunner.playMusic(resourceString: "ping", resourceType: "mp3")
                self.utterance = AVSpeechUtterance(string: foodItem.joke!)
                self.utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                self.synthesizer.speak(self.utterance)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Show Game Page") {
            
            let vc_ = segue.destination as! TTSortGameViewController
            vc_.foodItems = self.foodItems
        }    }
    

}
