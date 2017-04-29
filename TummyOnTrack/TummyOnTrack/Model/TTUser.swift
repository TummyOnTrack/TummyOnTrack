//
//  User.swift
//  TummyOnTrack
//
//  Created by yanze on 4/25/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTUser: NSObject {
    var username: String
    var email: String
    var dictionary: NSDictionary?

    init(username: String, email: String) {
        self.username = username
        self.email = email
    }

    init(dictionary: NSDictionary){
        self.dictionary = dictionary

        username = dictionary["username"] as! String
        email = dictionary["email"] as! String
    }
    
    func getProfiles(success: @escaping ([TTProfile]) -> (), failure: @escaping (NSError) -> ()) {
        /*let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)
        let query = ref.queryOrdered(byChild: "name")
        
        //get all of the comments tied to this post
        query.observeSingleEvent(of: .value, with: { snapshot in
            
            for snap in snapshot.children {
                //let snap_ = snap as! FIRDataSnapshot
            }
        })*/
        success([])
    }
    
    func addProfile( profile: TTProfile) {
        
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
