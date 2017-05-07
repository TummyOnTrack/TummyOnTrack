//
//  TTFillPlateViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import SVProgressHUD

class TTFillPlateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foodBlog: [TTDailyFoodEntry]!
    var foodItems = [TTFoodItem]()
    var dayOfWeek: String!
    var message: String!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        message = "Fetching food entries for " + dayOfWeek
        foodItems = []
        navigationItem.title = dayOfWeek + "'s Food"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if foodBlog.count == 0 {
            message = "Oops, No food entries for " + dayOfWeek
        }
        else {
            for i in 0...(foodBlog.count - 1) {
                let blog = foodBlog[i] as TTDailyFoodEntry
                for j in 0...((blog.items?.count)! - 1) {
                    let item_ = blog.items?[j]
                    foodItems.append(item_!)
                }
            }
        }
        
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // When movie view is empty, then show the empty view.
        // It will show the error from the server call if that is the reason for the empty movie set.
        if(foodItems.count == 0) {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            // label.center = CGPoint(x: 160, y: 285)
            label.textAlignment = .center
            label.text = message
            label.numberOfLines = 0
            tableView.backgroundView = label
            return 0
        }
        else {
            
            return foodItems.count
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "FillFoodCell") as! TTFillPlateTableCell
        cell.foodItem = foodItems[indexPath.row]
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
