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
        var imagesURLsArray = [String]()

        let imageSizes = [1, 2]

        for imageSize in imageSizes {
            let imageName = "\(filename)-\(imageSize)x"
            let image_ = UIImage(named: imageName)
            let data = UIImagePNGRepresentation(image_!)! as NSData
            var imageURL: String? = nil
            let storageRef = FIRStorage.storage().reference()

            // Create a reference to the file you want to upload
            let tempRef =  storageRef.child("profile_images").child("(imageName).png")

            _ = tempRef.put(data as Data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("An error occurred while uploading reward image")
                    return
                }

                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                imageURL = downloadURL()?.absoluteString

                if let imageURL = imageURL {
                    imagesURLsArray.append(imageURL)
                }
            }
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
