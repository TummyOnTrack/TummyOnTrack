//
//  ViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/24/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func logoutUser(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        UserDefaults.standard.removeObject(forKey: "currentLoggedInUserEmail")
        let mainStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let signupLoginVC = mainStoryboard.instantiateViewController(withIdentifier: "SignupLoginViewController") as! SignupLoginViewController
        self.present(signupLoginVC, animated: true, completion: nil)

    }


}

