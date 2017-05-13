//
//  TTFillPlateViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

// Emoji icons https://emojiisland.com/pages/free-download-emoji-icons-png
// star from https://clipartfest.com/categories/view/fa420d176735bb6ea61227cb310a9d5fa33efc1b/cute-star-clipart-png.html

import UIKit
import SVProgressHUD

class TTFillPlateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foodBlog: [TTDailyFoodEntry]!
    var foodItems = [TTFoodItem]()
    var sectionFoodItems : NSMutableDictionary = [:]
    var dayOfWeek: String!
    var message: String!
    var fullDayOfWeek: NSDictionary! = ["Sun": "Sunday", "Mon": "Monday", "Tues" : "Tuesday", "Wed" : "Wednesday", "Fri" : "Friday", "Sat" : "Saturday"]
    
    var categoryMessage: NSDictionary! = ["Protein": "Proteins make your bones stronger!", "Carbohydrate": "Eating carbs gives you energy to run around.", "Vegetable" : "Vegetables are full of Vitamins.", "Drink" : "A glass of water is the best drink for your body", "Fruit": "Fruits are yummy and good for you", "Dairy" : "Milk and cheese are full of calcium and proteins", "Dessert" : "Good job skipping dessert today!", "Other" : "Other"]
    
    var categories : NSArray! = ["Protein", "Vegetable", "Fruit", "Carbohydrate", "Dairy", "Drink", "Dessert", "Other" ]
    
    @IBOutlet weak var starButton: UIButton!
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        message = "Fetching food entries for " + (fullDayOfWeek[dayOfWeek] as! String)
        foodItems = []
        
        navigationItem.title = (fullDayOfWeek[dayOfWeek] as! String) + "'s Food Blog"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if foodBlog.count == 0 {
            message = "Oops, No food entries for " + (fullDayOfWeek[dayOfWeek] as! String)
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
        }
        populateSectionFoodItems()
        tableView.reloadData()
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
                    //let tag = categories.contains(tags_?[j]) .object(forKey: tags_?[j] ?? "x")
                    //if tag != nil {
                    print(tags_?[j] ?? "xx")
                    if categories.contains(tags_?[j] ?? "xx") {
                        let objs_ = sectionFoodItems.object(forKey: tags_?[j] ?? "x")
                        if objs_ == nil {
                            sectionFoodItems.setObject([item_], forKey: tags_?[j] as NSCopying? ?? "x" as NSCopying)
                        }
                        else {
                            var objArr_ = objs_ as! Array<Any>
                            objArr_.append(item_)
                            //sectionFoodItems.setObject(objArr_, forKey: tag as! NSCopying)
                            sectionFoodItems.setObject([item_], forKey: tags_?[j] as NSCopying? ?? "x" as NSCopying)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return categories.object(forKey: categories.allKeys[section]) as? String
        return categories.object(at: section) as? String
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(sectionFoodItems.count == 0) {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            // label.center = CGPoint(x: 160, y: 285)
            label.textAlignment = .center
            label.text = message
            label.numberOfLines = 0
            tableView.backgroundView = label
            return 0
        }
        else {
            tableView.backgroundView = nil
            if sectionFoodItems.object(forKey: categories.object(at: section)) == nil {
                return 1
            }
            return (sectionFoodItems.object(forKey: categories.object(at: section)) as! Array<Any>).count //foodItems.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objs_ = sectionFoodItems.object(forKey: categories.object(at: indexPath.section))
        if objs_ == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier:
                "MessageCell") as! TTMessageTableViewCell
            cell.messageLabel.text = categoryMessage.object(forKey: categories.object(at: indexPath.section)) as? String
            return cell
        }
        let objArr_ = objs_ as! Array<Any>
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "FillFoodCell") as! TTFillPlateTableCell
        //cell.foodItem = foodItems[indexPath.row]
        
        cell.foodItem = objArr_[indexPath.row] as! TTFoodItem
        return cell
    }
    
    @IBAction func onStarClick(_ sender: Any) {
        animateAchievement()
    }
    
    func animateAchievement() {
        
        
        // create a square image view
        let square1 = UIImageView()
        square1.frame = starButton.frame
        // Add image to the square
        square1.image = UIImage(named: "star-2")
        self.view.addSubview(square1)
        
        let square2 = UIImageView()
        square2.frame = starButton.frame
        // Add image to the square
        square2.image = UIImage(named: "star-2")
        self.view.addSubview(square2)
        
        let square3 = UIImageView()
        square3.frame = starButton.frame
        // Add image to the square
        square3.image = UIImage(named: "star-2")
        self.view.addSubview(square3)
        
        let square4 = UIImageView()
        square4.frame = starButton.frame
        // Add image to the square
        square4.image = UIImage(named: "star-2")
        self.view.addSubview(square4)
        
            UIView.animate(withDuration: 2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                square1.frame = CGRect(x: 0, y: self.view.frame.height+30, width: self.starButton.frame.size.width, height: self.starButton.frame.size.height)
                square2.frame = CGRect(x: 300, y: self.view.frame.height+30, width: self.starButton.frame.size.width, height: self.starButton.frame.size.height)
                square3.frame = CGRect(x: 140, y: self.view.frame.height+30, width: self.starButton.frame.size.width, height: self.starButton.frame.size.height)
                square4.frame = CGRect(x: 200, y: self.view.frame.height+30, width: self.starButton.frame.size.width, height: self.starButton.frame.size.height)
            }, completion: { (Bool) in
                square1.removeFromSuperview()
                square2.removeFromSuperview()
                square3.removeFromSuperview()
                square4.removeFromSuperview()
            })
        
    
        
        
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
