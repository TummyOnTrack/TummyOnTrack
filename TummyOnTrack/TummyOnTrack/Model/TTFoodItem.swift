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
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
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
    
    /*class func updateFoodItems(items: [NSDictionary], images: [URL], earnedPoints: Int, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        if let currentProfileName_ = TTProfile.currentProfile?.name {
            let ref1 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)
            let query = ref1.queryOrdered(byChild: "name").queryEqual(toValue: currentProfileName_)
            
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshot.children {
                    let snap_ = snap as! FIRDataSnapshot
                    print(snap_.key)
                    
                    let ref2 = FIRDatabase.database().reference(fromURL: BASE_URL).child(DAILYFOOD_TABLE).childByAutoId()
                    let dailyEntry = ["profile": TTProfile.currentProfile?.dictionary as Any, "items": items, "images": images, "earnedPoints" : earnedPoints, "createdAt": Date().timeIntervalSince1970, "updatedAt": Date().timeIntervalSince1970, "profileId": snap_.key] as [String: Any]
                    ref2.updateChildValues(dailyEntry)
                    
                    let ref3 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(snap_.key)")
                    let totalUnused = earnedPoints + (TTProfile.currentProfile?.unusedPoints)!
                    let totalWeekly = earnedPoints + (TTProfile.currentProfile?.weeklyEarnedPoints)!
                    ref3.updateChildValues(["unusedPoints": totalUnused, "weeklyPoints": totalWeekly])
                }
            })
        }
        else {
            print("No profile created")
        }
    }*/
}
