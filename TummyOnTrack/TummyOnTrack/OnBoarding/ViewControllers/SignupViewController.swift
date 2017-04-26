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
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPwdTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
  

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSignupButton()
        setupTextfields()
        
        navigationController?.navigationBar.barTintColor = .orange
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

    }

    @IBAction func signupUserClicked(_ sender: Any) {
        if passwordTextField.text! != confirmPwdTextField.text! {
            print("Password does not match confirmation")
            return
        }
        
        guard let username = emailTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
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
                let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.present(homeVC, animated: true, completion: nil)
            })
        })
    }
    
    func setupSignupButton() {
        signupButton.layer.cornerRadius = 3.5
    }
    
    func setupTextfields() {
        let leftImgView = UIImageView()
        leftImgView.image = UIImage(named: "user")
        leftImgView.contentMode = UIViewContentMode.scaleAspectFit
        
        let leftPaddingView = UIView()
        leftPaddingView.addSubview(leftImgView)
        
        leftPaddingView.frame = CGRect(x:0, y:0, width:30, height:20)
        leftImgView.frame = CGRect(x:8, y:0, width:20, height:18)
        
        usernameTextField.leftView = leftPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
    }


}
