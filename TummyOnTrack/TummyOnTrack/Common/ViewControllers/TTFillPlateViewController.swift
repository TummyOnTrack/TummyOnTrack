//
//  TTFillPlateViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTFillPlateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foodBlog: [TTDailyFoodEntry]!
    var foodItems = [TTFoodItem]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        foodItems = []
        
        for i in 0...(foodBlog.count - 1) {
            let blog = foodBlog[i] as TTDailyFoodEntry
            for j in 0...((blog.items?.count)! - 1) {
                let item_ = blog.items?[j]
                foodItems.append(item_!)
            }
        }
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItems.count
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
