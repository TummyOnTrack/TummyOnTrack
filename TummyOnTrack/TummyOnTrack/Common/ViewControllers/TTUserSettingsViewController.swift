//
//  TTUserSettingsViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class TTUserSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onLogoutClick(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        UserDefaults.standard.removeObject(forKey: "currentLoggedInUserEmail")
        let mainStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let signupLoginVC = mainStoryboard.instantiateViewController(withIdentifier: "SignupLoginViewController") as! SignupLoginViewController
        self.present(signupLoginVC, animated: true, completion: nil)
        

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
