//
//  User.swift
//  TummyOnTrack
//
//  Created by yanze on 4/25/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTUser: NSObject {
    var username: String
    var email: String
    
    init(username: String, email: String) {
        self.username = username
        self.email = email
    }
    
}
