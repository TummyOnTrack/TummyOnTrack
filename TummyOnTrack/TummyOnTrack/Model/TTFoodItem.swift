//
//  TTFoodItem.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTFoodItem {
    var name: String?
    var points: Int?
    var tags: [String]?
    var images: [URL]?
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        points = dictionary["points"] as? Int
        tags = dictionary["tags"] as? [String]
        var imageurls = [URL]()
        if let imagesdict = dictionary["images"] as? NSArray {
            for imageurlstring in imagesdict {
                if let imageurl = URL(string: imageurlstring as! String) {
                    imageurls.append(imageurl)
                }
            }
            images = imageurls
        }
    }

    static var defaultFoodList = [TTFoodItem]()

    class func getFoodItems(success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        let reference = FIRDatabase.database().reference(fromURL: BASE_URL).child(FOODITEM_TABLE)
        let query = reference.queryOrdered(byChild: "name")

        query.observeSingleEvent(of: .value, with: { snapshot in
            for snap in snapshot.children {
                let snap_ = snap as! FIRDataSnapshot
                let foodItem = TTFoodItem(dictionary: snap_.value! as! NSDictionary)

                self.defaultFoodList.append(foodItem)
            }
        })
    }
}
