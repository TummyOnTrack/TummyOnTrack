//
//  TTGameViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTGameViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var selectedFoodItems = [TTFoodItem]()
    var selectedFoodString: String!
    var defaultFoodNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedFoodString = "apple banana asparagus aubergine"
        checkForFoodItemsPresent()
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UICollectionViewDataSource protocol
extension TTGameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoodItems.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath as IndexPath) as! TTGameCollectionViewCell
        
       cell.foodItem = selectedFoodItems[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let foodItem_ = selectedFoodItems[indexPath.row]
        let cell =  collectionView.cellForItem(at: indexPath) as! TTGameCollectionViewCell
        
        if let imageurlstring = foodItem_.images?[0] {
            if let data = try? Data(contentsOf: imageurlstring) {
                let image_ = UIImage(data: data)
                let imageView_ = UIImageView(image: image_)
                imageView_.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.foodImageView.frame.width, height: cell.foodImageView.frame.height)
                view.addSubview(imageView_)
                UIView.animate(withDuration: 0.7, animations: {
                    imageView_.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height - imageView_.frame.height - 70, width: imageView_.frame.width, height: imageView_.frame.height)
                }, completion: { (Bool) in
                    
                })
                
            }
        }
    }
    
    
}

