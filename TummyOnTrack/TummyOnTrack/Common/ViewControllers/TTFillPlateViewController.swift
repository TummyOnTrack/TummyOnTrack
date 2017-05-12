//
//  TTFillPlateViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

// Emoji icons https://emojiisland.com/pages/free-download-emoji-icons-png

import UIKit
import SVProgressHUD

class TTFillPlateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foodBlog: [TTDailyFoodEntry]!
    var foodItems = [TTFoodItem]()
    var sectionFoodItems : NSMutableDictionary = [:]
    var dayOfWeek: String!
    var message: String!
    var fullDayOfWeek: NSDictionary! = ["Sun": "Sunday", "Mon": "Monday", "Tues" : "Tuesday", "Wed" : "Wednesday", "Fri" : "Friday", "Sat" : "Saturday"]
    
    var categories: NSDictionary! = ["Protein": "Proteins", "Carbohydrate": "Carbs", "Vegetable" : "Vegetable", "Drink" : "Drink", "Fruit": "Fruits", "Dairy" : "Dairy", "Dessert" : "Desserts and Sweets", "Other" : "Other"]
    
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
                for j in 0...(tags_?.count)!-1 {
                    let tag = categories.object(forKey: tags_?[j] ?? "x")
                    if tag != nil {
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
                    }
                    break
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
        return categories.object(forKey: categories.allKeys[section]) as? String
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
            if sectionFoodItems.object(forKey: categories.allKeys[section]) == nil {
                return 0
            }
            return (sectionFoodItems.object(forKey: categories.allKeys[section]) as! Array<Any>).count //foodItems.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "FillFoodCell") as! TTFillPlateTableCell
        //cell.foodItem = foodItems[indexPath.row]
        let objs_ = sectionFoodItems.object(forKey: categories.allKeys[indexPath.section]) as! Array<Any>
        cell.foodItem = objs_[indexPath.row] as! TTFoodItem
        return cell
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
