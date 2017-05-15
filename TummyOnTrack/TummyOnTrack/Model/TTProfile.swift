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

        if let rewardsItems = dictionary["rewards"] as? [NSDictionary] {
            for rewardsItem in rewardsItems {
                let reward = TTReward(dictionary: rewardsItem)
                rewards.append(reward)
            }
        }

        self.dictionary = dictionary.mutableCopy() as? NSMutableDictionary
    }

    static var _currentProfile: TTProfile?

    class var currentProfile: TTProfile?{
        get {
            if _currentProfile == nil {
                let defaults_ = UserDefaults.standard
                let profileData_ = defaults_.object(forKey: "currentProfileData") as? NSData
                if let profileData_ = profileData_ {
                    let dictionary_ = try! JSONSerialization.jsonObject(with: profileData_ as Data, options: []) as! NSDictionary
                    _currentProfile = TTProfile(dictionary: dictionary_)
                }
            }
            return _currentProfile
        }
        set(profile) {
            
            _currentProfile = profile
            let defaults_ = UserDefaults.standard
            if let profile = profile {
                
                let data_ = try! JSONSerialization.data(withJSONObject:  profile.dictionary! as Any, options: [])
                defaults_.set(data_, forKey: "currentProfileData")
                defaults_.synchronize()
                
            }
            else {
                defaults_.removeObject(forKey: "currentProfileData")
                defaults_.synchronize()
            }

        }
    }
    
    func getWeeklyFoodBlog(success: @escaping ([TTDailyFoodEntry]) -> (), failure: @escaping (NSError) -> ()) {
        weeklyFoodBlog.removeAllObjects()
        foodBlog.removeAllObjects()
        let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(DAILYFOOD_TABLE)
        let query = ref.queryOrdered(byChild: "profileId").queryEqual(toValue: profileId)

        query.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                success([TTDailyFoodEntry]())
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
        weeklyEarnedPoints = 0
        let weekDay = Calendar.current.component(.weekday, from: Date())
        
        let dateDaysAgo = Calendar.current.date(byAdding: .day, value: -(weekDay-1), to: Date())
        
        for i in 0...(foodBlog.count-1) {
            let blog = foodBlog[i] as! TTDailyFoodEntry
            /**/
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date1String = dateFormatter.string(from: blog.createdAt!)
            let date2String = dateFormatter.string(from: dateDaysAgo!)
            // compare today's dates separately, otherwise it creates problems with timestamp
            if date1String >= date2String {
                weeklyFoodBlog.add(blog)
                weeklyEarnedPoints = weeklyEarnedPoints + blog.earnedPoints!
            }
            else if blog.createdAt! >= dateDaysAgo! {
                weeklyFoodBlog.add(blog)
                weeklyEarnedPoints = weeklyEarnedPoints + blog.earnedPoints!
            }
        }
        updateProfile(dictionary: ["weeklyEarnedPoints": weeklyEarnedPoints])
    }
    
    func updateFoodItems(items: [NSDictionary], images: [URL], earnedPoints: Int, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {

        if let currentProfileId_ = TTProfile.currentProfile?.profileId {
            let ref1 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(currentProfileId_)")
            let ref2 = FIRDatabase.database().reference(fromURL: BASE_URL).child(DAILYFOOD_TABLE).childByAutoId()
            
            
            let dailyEntry = ["profile": self.dictionary as Any, "items": items, "images": images, "earnedPoints" : earnedPoints, "createdAt": Date().timeIntervalSince1970, "updatedAt": Date().timeIntervalSince1970, "profileId": currentProfileId_/*snap_.key*/] as [String: Any]
            self.weeklyFoodBlog.add(TTDailyFoodEntry.init(dictionary: dailyEntry as NSDictionary))
            ref2.updateChildValues(dailyEntry)
            
            let totalUnused = earnedPoints + (self.unusedPoints)
            let totalWeekly = earnedPoints + (self.weeklyEarnedPoints)
            //locally update points
            self.unusedPoints = self.unusedPoints + earnedPoints
            self.totalPoints = self.totalPoints + earnedPoints
            self.weeklyEarnedPoints = self.weeklyEarnedPoints + earnedPoints
            TTUser.currentUser?.replaceProfile(aProfile: self)
            ref1.updateChildValues(["unusedPoints": totalUnused, "weeklyPoints": totalWeekly])
            
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileChanged"), object: nil)
        }
        else {
            print("No profile created")
        }
    }
    
    // Updates unusedPoints and rewards array
    func updateRewards(unusedPoints: Int, rewards: [TTReward], success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if let currentProfileId_ = TTProfile.currentProfile?.profileId {
            let ref1 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(currentProfileId_)")
            var rewardsDictionary = [NSDictionary]()
            for reward in rewards {
                rewardsDictionary.append(reward.dictionary)
            }
            self.unusedPoints = unusedPoints
            self.rewards = rewards
            TTUser.currentUser?.replaceProfile(aProfile: self)
            ref1.updateChildValues(["unusedPoints": unusedPoints, "rewards": rewardsDictionary])
        }
        else {
            print("No profile created")
        }
    }
    
    func setGoalPoints(aGoalPoints: Int) {
        goalPoints = aGoalPoints
        updateProfile(dictionary: ["goalPoints": goalPoints])
        TTUser.currentUser?.replaceProfile(aProfile: self)
    }
    
    func updateProfile(dictionary: NSDictionary) {
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
                let ref2 = FIRDatabase.database().reference(fromURL: BASE_URL).child(PROFILES_TABLE+"/\(snap_.key)")

                ref2.updateChildValues(dictionary as! [AnyHashable : Any])
                
            }
        })
    }

    class func changeProfile(profile: TTProfile) {
        TTProfile.currentProfile = profile
    }
}
