//
//  TTJoke.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/13/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

//source: http://www.jokes4us.com/miscellaneousjokes/foodjokes/baconjokes.html"

class TTJoke: NSObject {
    
    static let jokes: NSMutableDictionary! = ["Apple": "What lives in apples and is an avid reader? A bookworm !", "Bacon" : "What do you call a bacon wrapped dinosaur? Jurrasic Pork.", "Egg" : "What day do eggs hate most? Fry-day!", "Eggs" : "What day do eggs hate most? Fry-day!", "Broccoli" : "What do you get when you cross broccoli and a vampire? Count Broccula!", "Strawberry" : "Patient: Doctor, there is a strawberry growing out of my head. Doctor: Oh, that's easy. Just put some cream on it!"]
    
    class func getJokeFor(aWord: String) -> String? {
        let joke_ = TTJoke.jokes.object(forKey: aWord)
        if joke_ == nil {
            return nil
        }
        return joke_ as? String
    }
    

}
