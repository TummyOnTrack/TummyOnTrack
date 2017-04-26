//
//  LoginViewController.swift
//  TummyOnTrack
//
//  Created by yanze on 4/25/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginUserClicked(_ sender: Any) {
        guard let email = emailLabel.text, let password = passwordLabel.text else {
            print("Please enter valid login information")
            return
        }
        loginUserWith(email: email, password: password)
        
    }

    func loginUserWith(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print("Login user error: \(error)")
            }
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.present(homeVC, animated: true, completion: nil)
        })
    }

}
