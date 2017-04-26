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
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
      
    }
    
    func setupLoginButton() {
        loginButton.layer.cornerRadius = 3.5
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
                print("Login user error: \(String(describing: error))")
                return
            }
            
            UserDefaults.standard.set(email, forKey: "currentLoggedInUserEmail")
            UserDefaults.standard.synchronize()
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "MainPageTabBarController") as! UITabBarController
            self.present(homeVC, animated: true, completion: nil)
        })
    }

}
