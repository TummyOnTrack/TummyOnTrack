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
        }
        self.imageURLs = imageURLs
    }

    class func getRewards(success: @escaping ([TTReward]) -> (), failure: @escaping (NSError) -> ()) {
        let reference = FIRDatabase.database().reference(fromURL: BASE_URL).child(REWARDS_TABLE)
        let query = reference.queryOrdered(byChild: "name")

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

    class func addReward(filename: String, points: Int) {
        let imageSizes = [1]

        for imageSize in imageSizes {
            let imageName = "\(filename)-\(imageSize)x"
            let image = UIImage(named: imageName)
            let storageRef = FIRStorage.storage().reference().child("rewardImages").child("\(imageName).png")

            if let imgData = UIImagePNGRepresentation(image!) {
                storageRef.put(imgData, metadata: nil) { (metaData, error) in
                    if error != nil {
                        print("Error when uploading reward image to storage \(String(describing: error)) in TTReward")
                    }
                    var imagesURLsArray = [String]()

                    if let imageUrl = metaData?.downloadURL()?.absoluteString {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        imagesURLsArray.append(imageUrl)
                    }

                    // Use the imagesURLsArray to create a reward object to add to the firebase database
                    let reference = FIRDatabase.database().reference(fromURL: BASE_URL).child(REWARDS_TABLE).childByAutoId()
                    let values = [
                        "name": filename,
                        "points": points,
                        "createdAt": Date().timeIntervalSince1970,
                        "updatedAt": Date().timeIntervalSince1970,
                        "images" : imagesURLsArray,
                        ] as [String : Any]

                    reference.updateChildValues(values)
                }
            }
        }
    }
}
