//
//  TTFoodInputWaysViewController.swift
//  TummyOnTrack


//
//  Created by Gauri Tikekar on 4/27/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTFoodInputWaysViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onSpeakTellClick(_ sender: Any) {
        if let viewController = UIStoryboard(name: "VoiceEntry", bundle: nil).instantiateViewController(withIdentifier: "TTVoiceViewController") as? TTVoiceViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
