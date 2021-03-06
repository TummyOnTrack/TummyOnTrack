//
//  TTReward.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/28/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//
import UIKit
import Firebase
import FirebaseStorage

class TTReward: NSObject {
    var name: String?
    var points: Int?
    var imageURLs = [URL]()
    var thumbnail: UIImage?
    var thumbnailURL: URL?
    var largeImageURL: URL?
    var dictionary: NSDictionary!

    static var rewards = [String: TTReward]()

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        name = dictionary["name"] as? String
        points = dictionary["points"] as? Int

        if let imagesDictionary = dictionary["images"] as? NSArray {
            for (index, imageURLString) in imagesDictionary.enumerated() {
                if let imageURL = URL(string: imageURLString as! String) {
                    imageURLs.append(imageURL)
                    switch index {
                    case 0:
                        thumbnailURL = imageURL
                    case 1:
                        largeImageURL = imageURL
                    default:
                        print("No images for rewards!")
                    }
                }
            }
        }
    }

    class func getRewards(success: @escaping ([TTReward]) -> (), failure: @escaping (NSError) -> ()) {
        let reference = FIRDatabase.database().reference(fromURL: BASE_URL).child(REWARDS_TABLE)
        let query = reference.queryOrdered(byChild: "points")

        query.observeSingleEvent(of: .value, with: { snapshot in
            var rewards = [TTReward]()

            for snap in snapshot.children {
                let snap_ = snap as! FIRDataSnapshot
                let reward = TTReward(dictionary: snap_.value! as! NSDictionary)

                if let name = reward.name {
                    self.rewards[name] = reward
                }

                rewards.append(reward)
            }
            success(rewards)
        })
    }

    func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {

        guard let thumbnail = thumbnail else {
            return size
        }

        let imageSize = thumbnail.size
        var returnSize = size

        let aspectRatio = imageSize.width / imageSize.height

        returnSize.height = returnSize.width / aspectRatio

        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }

        return returnSize
    }
}
