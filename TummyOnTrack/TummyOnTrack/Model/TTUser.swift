//
//  User.swift
//  TummyOnTrack
//
//  Created by yanze on 4/25/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class TTUser: NSObject {
    var username: String
    var email: String
    var uid: String
    var dictionary: NSDictionary?
    var profiles: NSMutableArray?

    init(username: String, email: String, uid: String) {
        self.username = username
        self.email = email
        self.uid = uid
    }

    init(dictionary: NSDictionary){
        self.dictionary = dictionary

        username = dictionary["username"] as! String
        email = dictionary["email"] as! String
        uid = dictionary["uid"] as! String
    }
    
    func getProfiles(success: @escaping ([TTProfile]) -> (), failure: @escaping (NSError) -> ()) {
        if profiles != nil && (profiles?.count)! > 0 {
            success(profiles as! [TTProfile])
            return
        }
        if profiles == nil {
            profiles = []
        }
        let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)
        let query = ref.queryOrdered(byChild: "userId").queryEqual(toValue: uid)
        
        //get all of the comments tied to this post
        query.observeSingleEvent(of: .value, with: { snapshot in
            
            for snap in snapshot.children {
                let snap_ = snap as! FIRDataSnapshot
                let profile_ = TTProfile(dictionary: snap_.value! as! NSDictionary)
                self.profiles?.add(profile_)
            }
            success(self.profiles as! [TTProfile])
        })
    }
    
    func changeCurrentProfile( aProfile: TTProfile ) {
        TTProfile.changeProfile(profile: aProfile)
    }
    
    func addProfile( aProfile: TTProfile) {
        // Data in memory
        
        let image_ = UIImage(named: "user")
        let data = UIImagePNGRepresentation(image_!)! as NSData
        var imageURL: String? = nil
        let storageRef = FIRStorage.storage().reference()
        // Create a reference to the file you want to upload
        let tempRef =  storageRef.child("profileImages/temp2.png")
        
        _ = tempRef.put(data as Data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            imageURL = downloadURL()?.absoluteString
            
            // User this imageurl, create a profile object and add that in the firebase database
            let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE).childByAutoId()
            let prof_ = ["name": "John", "age": 6, "createdAt": Date().timeIntervalSince1970, "updatedAt": Date().timeIntervalSince1970, "profilePhoto" : imageURL ?? "", "userId" : self.uid, "user" : self.dictionary ?? ""] as [String : Any]
            let values = prof_
            ref.updateChildValues(values)
        }

    }

    static var userAccounts = [String: TTUser]()
    static var _currentUser: TTUser?

    class var currentUser: TTUser?{
        get {
            if _currentUser == nil {
                if userAccounts.isEmpty == true {
                    print("no users")
                }
                let defaults = UserDefaults.standard

                let usersData = defaults.object(forKey: "currentUserData") as? [String: Data]
                if let usersData = usersData {
                    for (_, uservalue) in usersData {
                        let dictionary = try! JSONSerialization.jsonObject(with: uservalue, options: []) as! NSDictionary
                        _currentUser = TTUser(dictionary: dictionary)
                        if userAccounts[(_currentUser?.username)!] == nil {
                            userAccounts[(_currentUser?.username)!] = _currentUser
                        }
                    }

                }
            }
            return _currentUser
        }
        set(user) {
            if user == nil {
                userAccounts.removeValue(forKey: (_currentUser?.username)!)
                _currentUser = user

            }
            else {
                _currentUser = user
                userAccounts[(_currentUser?.username)!] = _currentUser
            }

            let defaults = UserDefaults.standard

            if userAccounts.isEmpty {
                defaults.removeObject(forKey: "currentUserData")
            }
            else {
                var userData = [String: Data]()
                for (userkey, uservalue) in userAccounts {
                    let data = try! JSONSerialization.data(withJSONObject: uservalue.dictionary!, options: [])
                    userData[userkey] = data
                }
                defaults.set(userData, forKey: "currentUserData")
            }

            defaults.synchronize()

        }
    }

    class func changeUser(user: TTUser) {
        if userAccounts[user.username] != nil {
            _currentUser = user
        }
    }
    
    class func delete(user: TTUser) {
        if _currentUser?.username == user.username {
            for (_, value) in userAccounts {
                if value.username != _currentUser?.username {
                    _currentUser = value
                    break
                }
            }
        }
        if userAccounts[user.username] != nil {
            userAccounts.removeValue(forKey: user.username)
        }
    }
}
