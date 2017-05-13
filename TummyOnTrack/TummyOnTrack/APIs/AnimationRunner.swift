//
//  AnimationRunner.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/13/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import AVFoundation

class AnimationRunner: NSObject, AVAudioPlayerDelegate {
    
    var audioPlayer : AVAudioPlayer!
    
    func playMusic() {
        
        //let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "bubble", ofType: "mp3")!)
        let alertSound = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "fun_kids_half" as CFString!, "mp3" as CFString!, nil)!
        
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: alertSound as URL)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            // Create an assertion crash in the event that the app fails to play the sound
            assert(false, error.localizedDescription)
        }
        
        
    }


}
