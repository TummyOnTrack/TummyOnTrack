//
//  TTFirebaseClient.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/29/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

let BASE_URL = "https://tummyontrack.firebaseio.com/"

let PROFILES_TABLE = "Profiles"
let REWARDS_TABLE = "Rewards"
let USERS_TABLE = "Users"


class TTFirebaseClient: NSObject {
    
    class func saveCurrentUser() {
        
        let ref = FIRDatabase.database().reference(fromURL: BASE_URL).child(USERS_TABLE)
        print((FIRAuth.auth()?.currentUser?.uid)!)
        let LoggedInUser = ref.child((FIRAuth.auth()?.currentUser?.uid)!)
        LoggedInUser.observeSingleEvent(of: .value, with: { snapshot in
            let snap_ = snapshot
            //print(snap_.value!)
            
            let dictionary_: NSMutableDictionary = [:]
            dictionary_.addEntries(from: snap_.value! as! [AnyHashable : Any])
            dictionary_.setObject(FIRAuth.auth()?.currentUser?.uid ?? "", forKey: "uid" as NSCopying)

            TTUser.currentUser = TTUser.init(dictionary: dictionary_ as NSDictionary)
        })
    }

}
