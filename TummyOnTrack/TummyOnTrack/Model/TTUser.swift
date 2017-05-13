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
    var profiles: NSMutableArray
    

    init(username: String, email: String, uid: String) {
        self.username = username
        self.email = email
        self.uid = uid
        self.profiles = []
    }

    init(dictionary: NSDictionary){
        self.dictionary = dictionary

        username = dictionary["username"] as! String
        email = dictionary["email"] as! String
        uid = dictionary["uid"] as! String
        profiles = []
    }
    
    func getProfiles(success: @escaping ([TTProfile]) -> (), failure: @escaping (NSError) -> ()) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            // uid is nil
            return
        }
        if profiles.count > 0 {
            success(profiles as! [TTProfile])
            return
        }
        let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)

        let query = ref.queryOrdered(byChild: "userId").queryEqual(toValue: uid)

        query.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                success(self.profiles as! [TTProfile])
                return
            }
            for profile in snapshot.children.allObjects as! [FIRDataSnapshot] {
                var val = profile.value as! [String: Any]
                val["profileId"] = profile.key
                let profile = TTProfile(dictionary: val as NSDictionary)
                //allProfiles.append(profile)
                self.profiles.add(profile)
            }
            success(self.profiles as! [TTProfile])

        })
    }
    
    func changeCurrentProfile( aProfile: TTProfile ) {
        TTProfile.currentProfile = aProfile
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
    }
    
    func addProfile(name: String, age: Int, image: UIImage, completionHandler: @escaping(Bool) -> Void) {
        let imageFileName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageFileName).png")
        
        if let imgData = UIImageJPEGRepresentation(image, 0.1) {
            storageRef.put(imgData, metadata: nil) { (metaData, error) in
                if error != nil {
                    print("error when uploading profile image to storage \(String(describing: error)) in TTUser")
                }
                if let profileImgUrl = metaData?.downloadURL()?.absoluteString {
                    let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE).childByAutoId()
                    var profileValues = ["name": name, "age": age, "createdAt": Date().timeIntervalSince1970, "updatedAt": Date().timeIntervalSince1970, "profilePhoto" : profileImgUrl, "userId" : self.uid, "user" : self.dictionary as Any, "goalPoints" : 50] as [String : Any]
                    ref.updateChildValues(profileValues)
                    profileValues["profileId"] = ref.key
                    let addedProfile = TTProfile.init(dictionary: profileValues as NSDictionary)
                    self.profiles.add(addedProfile)
                    self.changeCurrentProfile(aProfile: addedProfile)
                    completionHandler(true)
                    
                }
            }
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
    
    func replaceProfile(aProfile: TTProfile) {
        if profiles.count > 0 {
            for i in 0...(profiles.count)-1 {
                if aProfile.name == (profiles[i] as! TTProfile).name {
                    profiles[i] = aProfile
                    break
                }
            }
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
