//
//  TTProfile.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/29/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTProfile: NSObject {
    var name: String?
    var profileId: String?
    var age: Int?
    var profileImageURL: URL?
    var isParent: Bool = false
    var unusedPoints: Int = 0
    var weeklyEarnedPoints: Int = 0
    var totalPoints: Int = 0
    var goalPoints: Int = 50
    var user: TTUser?
    var rewards: [TTReward] = [TTReward]()
    var dictionary: NSMutableDictionary?
    var weeklyFoodBlog: NSMutableArray
    var foodBlog: NSMutableArray
    
    /*override init() {
        super.init()
        self.weeklyFoodBlog = []
    }*/

    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        age = dictionary["age"] as? Int
        profileId = dictionary["profileId"] as? String
        weeklyFoodBlog = []
        foodBlog = []

        if let profileImageString = dictionary["profilePhoto"] as? String {
            profileImageURL = URL(string: profileImageString)
        }

        if let isParent = dictionary["isParent"] as? Bool {
            self.isParent = isParent
        } else {
            self.isParent = false
        }

        if let unusedPoints = dictionary["unusedPoints"] as? Int {
            self.unusedPoints = unusedPoints
        } else {
            self.unusedPoints = 0
        }
        
        if let weeklyPoints = dictionary["weeklyPoints"] as? Int {
            self.weeklyEarnedPoints = weeklyPoints
        } else {
            self.weeklyEarnedPoints = 0
        }

        if let totalPoints = dictionary["totalPoints"] as? Int {
            self.totalPoints = totalPoints
        } else {
            self.totalPoints = 0
        }

        if let goalPoints = dictionary["goalPoints"] as? Int {
            self.goalPoints = goalPoints
        } else {
            self.goalPoints = 50
        }

        if let user_name = dictionary["user_name"] as? String {
            if let user = TTUser.userAccounts[user_name] {
                self.user = user
            }
        }

        if let rewardsItems = dictionary["rewards"] as? [String] {
            rewards = [TTReward]()
            for rewardsItem in rewardsItems {
                if let reward = TTReward.rewards[rewardsItem] {
                    rewards.append(reward)
                }
            }
        }

        self.dictionary = dictionary.mutableCopy() as? NSMutableDictionary
    }
    

    static var profiles = [String: TTProfile]()
    static var _currentProfile: TTProfile?

    class var currentProfile: TTProfile?{
        get {
            if _currentProfile == nil {
                if profiles.isEmpty == true {
                    print("no profiles")
                    
                }
                let defaults = UserDefaults.standard

                let profilesData = defaults.object(forKey: "currentProfileData") as? [String: Data]
                if let profilesData = profilesData {
                    for (_, profilevalue) in profilesData {
                        let dictionary = try! JSONSerialization.jsonObject(with: profilevalue, options: []) as! NSDictionary
                        //dictionary["profileId"] = profilesData.key
                        _currentProfile = TTProfile(dictionary: dictionary)
                        if profiles[(_currentProfile?.name)!] == nil {
                            profiles[(_currentProfile?.name)!] = _currentProfile
                        }
                    }

                }
            }
            return _currentProfile
        }
        set(profile) {
            if profile == nil {
                profiles.removeValue(forKey: (_currentProfile?.name)!)
                _currentProfile = profile

            }
            else {
                _currentProfile = profile
                profiles[(_currentProfile?.name)!] = _currentProfile
            }

            let defaults = UserDefaults.standard

            if profiles.isEmpty {
                defaults.removeObject(forKey: "currentProfileData")
            }
            else {
                var profileData = [String: Data]()
                for (profilekey, profilevalue) in profiles {
                    let data = try! JSONSerialization.data(withJSONObject: profilevalue.dictionary!, options: [])
                    profileData[profilekey] = data
                }
                defaults.set(profileData, forKey: "currentProfileData")
            }

            defaults.synchronize()
        }
    }
    
    func getWeeklyFoodBlog(success: @escaping ([TTDailyFoodEntry]) -> (), failure: @escaping (NSError) -> ()) {
        
        /*if weeklyFoodBlog.count > 0 {
            success(weeklyFoodBlog as! [TTDailyFoodEntry])
            return
        }*/
        weeklyFoodBlog.removeAllObjects()
        foodBlog.removeAllObjects()
        let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(DAILYFOOD_TABLE)
        
        //let weekDay = Calendar.current.component(.weekday, from: Date())
        //let daysAgo = Calendar.current.date(byAdding: .day, value: -weekDay-1, to: Date())
        
        let query = ref.queryOrdered(byChild: "profileId").queryEqual(toValue: profileId)
        //.queryOrdered(byChild: "createdAt").queryStarting(atValue: Date().timeIntervalSince1970).queryEnding(atValue: daysAgo?.timeIntervalSince1970)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                //success() //self.weeklyFoodBlog as! [TTDailyFoodEntry])
                //failure(nil)
                return
            }
            for profile in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                let val = profile.value as! [String: Any]
                let blog = TTDailyFoodEntry(dictionary: val as NSDictionary)
                self.foodBlog.add(blog)
                
            }
            self.extractWeeklyBlog()
            success(self.weeklyFoodBlog as! [TTDailyFoodEntry])
            
        })
        
    }
    
    func extractWeeklyBlog() {
        let weekDay = Calendar.current.component(.weekday, from: Date())
        let daysAgo = Calendar.current.date(byAdding: .day, value: -weekDay-1, to: Date())
        
        for i in 0...(foodBlog.count-1) {
            let blog = foodBlog[i] as! TTDailyFoodEntry
            if Double((blog.createdAt?.timeIntervalSince1970)!) >= Double((daysAgo?.timeIntervalSince1970)!) {
                weeklyFoodBlog.add(blog)
            }
        }
    }
    
    func updateFoodItems(items: [NSDictionary], images: [URL], earnedPoints: Int, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        if let currentProfileName_ = TTProfile.currentProfile?.name {
            let ref1 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)
            let query = ref1.queryOrdered(byChild: "name").queryEqual(toValue: currentProfileName_)
            
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshot.children {
                    let snap_ = snap as! FIRDataSnapshot
                    print(snap_.key)
                    
                    let ref2 = FIRDatabase.database().reference(fromURL: BASE_URL).child(DAILYFOOD_TABLE).childByAutoId()
                    let dailyEntry = ["profile": self.dictionary as Any, "items": items, "images": images, "earnedPoints" : earnedPoints, "createdAt": Date().timeIntervalSince1970, "updatedAt": Date().timeIntervalSince1970, "profileId": snap_.key] as [String: Any]
                    self.weeklyFoodBlog.add(TTDailyFoodEntry.init(dictionary: dailyEntry as NSDictionary))
                    ref2.updateChildValues(dailyEntry)
                    
                    let ref3 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(snap_.key)")
                    let totalUnused = earnedPoints + (self.unusedPoints)
                    let totalWeekly = earnedPoints + (self.weeklyEarnedPoints)
                    ref3.updateChildValues(["unusedPoints": totalUnused, "weeklyPoints": totalWeekly])
                }
            })
        }
        else {
            print("No profile created")
        }
    }


    
    func setGoalPoints(aGoalPoints: Int) {
        goalPoints = aGoalPoints
        TTUser.currentUser?.replaceProfile(aProfile: self)
    }
    
    func updateProfile(dictionary: NSDictionary) {
        
        name = dictionary["name"] as? String
        age = dictionary["age"] as? Int
        
        if let profileImageString = dictionary["profilePhoto"] as? String {
            profileImageURL = URL(string: profileImageString)
        }
        
        if let isParent = dictionary["isParent"] as? Bool {
            self.isParent = isParent
        } else {
            self.isParent = false
        }
        
        if let unusedPoints = dictionary["unusedPoints"] as? Int {
            self.unusedPoints = unusedPoints
        }
        
        if let weeklyPoints = dictionary["weeklyEarnedPoints"] as? Int {
            self.weeklyEarnedPoints = weeklyPoints
        }
        
        if let totalPoints = dictionary["totalPoints"] as? Int {
            self.totalPoints = totalPoints
        }
        
        if let goalPoints = dictionary["goalPoints"] as? Int {
            self.goalPoints = goalPoints
        }
        
        if let user_name = dictionary["user_name"] as? String {
            if let user = TTUser.userAccounts[user_name] {
                self.user = user
            }
        }
        
        if let rewardsItems = dictionary["rewards"] as? [String] {
            rewards = [TTReward]()
            for rewardsItem in rewardsItems {
                if let reward = TTReward.rewards[rewardsItem] {
                    rewards.append(reward)
                }
            }
        }
        
        self.dictionary?.addEntries(from: dictionary as! [AnyHashable : Any])
        
        let ref1 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE)
        let query = ref1.queryOrdered(byChild: "name").queryEqual(toValue: name)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let snap_ = snap as! FIRDataSnapshot
                print(snap_.key)
                let ref2 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(snap_.key)")

                ref2.updateChildValues(dictionary as! [AnyHashable : Any])
            }
        })
        

    }

    class func changeProfile(profile: TTProfile) {
        if profiles[profile.name!] != nil {
            _currentProfile = profile
        }
    }

    class func delete(profile: TTProfile) {
        if _currentProfile?.name == profile.name {
            for (_, value) in profiles {
                if value.name != _currentProfile?.name {
                    _currentProfile = value
                    break
                }
            }
        }
        if profiles[profile.name!] != nil {
            profiles.removeValue(forKey: profile.name!)
        }
    }
}
