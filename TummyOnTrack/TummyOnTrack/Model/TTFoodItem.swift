//
//  TTFoodItem.swift
//  TummyOnTrack
//
//  Created by Pooja Chowdhary on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

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
}
