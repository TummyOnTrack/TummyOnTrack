//
//  SignupViewController.swift
//  TummyOnTrack
//
//  Created by yanze on 4/25/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPwdLabel: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSignupButton()
        
        navigationController?.navigationBar.barTintColor = .orange
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
       
    }
    
    func setupSignupButton() {
        signupButton.layer.cornerRadius = 3.5
    }

    @IBAction func signupUserClicked(_ sender: Any) {
        if passwordLabel.text! != confirmPwdLabel.text! {
            print("Password does not match confirmation")
            return
        }
        
        guard let username = usernameLabel.text, let email = emailLabel.text, let password = passwordLabel.text else {
            print("Please enter valid sign up information")
            return
        }
        
        signupUser(username: username, email: email, password: password)
        
    }
    
    func signupUser(username: String, email: String, password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error as Any)
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successful
            let dbReference = FIRDatabase.database().reference(fromURL: "https://tummyontrack.firebaseio.com/").child("Users").child(uid)
            let newUser = ["username": username, "email": email, "createdAt": Date().timeIntervalSince1970] as [String : Any]
            dbReference.updateChildValues(newUser, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print("signup user error: \(String(describing: err))")
                    return
                }
                
                print("Saved user successfully into DB")
                UserDefaults.standard.set(email, forKey: "currentLoggedInUserEmail")
                UserDefaults.standard.synchronize()
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "MainPageTabBarController") as! UITabBarController
                self.present(homeVC, animated: true, completion: nil)
            })
        })
    }


}
