//
//  TTDailyFoodEntry.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/6/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTDailyFoodEntry: NSObject {
    var createdAt: Date?
    var earnedPoints: Int?
    var items : [TTFoodItem]?
    var profileId : String?
    var weekDay: Int?

    init(dictionary: NSDictionary) {
        profileId = dictionary["profileId"] as? String
        
        createdAt = NSDate(timeIntervalSince1970: (dictionary["createdAt"] as? Double)!) as Date
        weekDay = Calendar.current.component(.weekday, from: createdAt!)
        
        if let earnedPoints = dictionary["earnedPoints"] as? Int {
            self.earnedPoints = earnedPoints
        } else {
            self.earnedPoints = 0
        }
        items = []
        if let itemsDictionary = dictionary["items"] as? NSArray {
            for (_, item) in itemsDictionary.enumerated() {
                let item_ = TTFoodItem.init(dictionary: item as! NSDictionary)
                //items?.add(item_)
                items?.append(item_)
            }
        }
    }
}
