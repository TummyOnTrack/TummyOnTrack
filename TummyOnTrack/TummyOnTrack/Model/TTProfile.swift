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
    var isParent: Bool?
    var unusedPoints: Int?
    var totalPoints: Int?
    var goalPoints: Int?
    var user: TTUser?
    var rewards: [TTReward]?
    var dictionary: NSDictionary?

    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        age = dictionary["age"] as? Int

        if let profileImageString = dictionary["profilePhoto"] as? String {
            profileImageURL = URL(string: profileImageString)
        }

        isParent = dictionary["isParent"] as? Bool
        unusedPoints = dictionary["unusedPoints"] as? Int
        totalPoints = dictionary["totalPoints"] as? Int
        goalPoints = dictionary["goalPoints"] as? Int

        if let user_name = dictionary["user_name"] as? String {
            if let user = TTUser.userAccounts[user_name] {
                self.user = user
            }
        }

        if let rewardsItems = dictionary["rewards"] as? [String] {
            rewards = [TTReward]()
            for rewardsItem in rewardsItems {
                if let reward = TTReward.rewards[rewardsItem] {
                    rewards?.append(reward)
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
