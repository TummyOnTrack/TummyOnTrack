//
//  TTReward.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTReward: NSObject {
    var name: String?
    var points: Int?
    var imageURLs: [URL]?

    static var rewards = [String: TTReward]()

    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        points = dictionary["points"] as? Int
        var imageURLs = [URL]()

        if let imagesDictionary = dictionary["images"] as? NSArray {
            for imageURLString in imagesDictionary {
                if let imageURL = URL(string: imageURLString as! String) {
                    imageURLs.append(imageURL)
                }

            }
            self.imageURLs = imageURLs
        }
    }
}
