//
//  TTProfile.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 4/29/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTProfile: NSObject {
    var name: String?
    var age: Int?
    var profileImageURL: URL?
    var isParent: Bool = false
    var unusedPoints: Int = 0
    var weeklyEarnedPoints: Int = 0
    var totalPoints: Int = 0
    var goalPoints: Int = 50
    var user: TTUser?
    var rewards: [TTReward] = [TTReward]()
    var dictionary: NSDictionary?
    
    override init() {
        super.init()
        
    }

    
    init(dictionary: NSDictionary) {
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
        } else {
            self.unusedPoints = 0
        }
        
        if let weeklyPoints = dictionary["weeklyEarnedPoints"] as? Int {
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

        self.dictionary = dictionary
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
    
    func setGoalPoints(aGoalPoints: Int) {
        goalPoints = aGoalPoints
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
