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
    @IBOutlet var errorView: UIView!
    @IBOutlet weak var errorViewLabel: UILabel!
  

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSignupButton()
        setupTextfields()
        
        navigationController?.navigationBar.barTintColor = .orange
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        usernameTextField.becomeFirstResponder()
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPwdTextField.delegate = self

    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
//    }
    

    @IBAction func signupUserClicked(_ sender: Any) {
        guard let username = emailTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPwd = confirmPwdTextField.text else {
            return
        }
        if username.isEmpty || email.isEmpty || password.isEmpty {
            Helpers.sharedInstance.showErrorMessageAlertDialog("Please enter valid sign up information", errorView: errorView, errorLabel: errorViewLabel, parentView: view, navController: navigationController!)
            return
        }
        else if password != confirmPwd {
            Helpers.sharedInstance.showErrorMessageAlertDialog("Password does not match confirmation", errorView: errorView, errorLabel: errorViewLabel, parentView: view, navController: navigationController!)
            return
        }
        else if password.characters.count < 6 {
            Helpers.sharedInstance.showErrorMessageAlertDialog("Password must be more than 6 letters", errorView: errorView, errorLabel: errorViewLabel, parentView: view, navController: navigationController!)
            return
        }
        
        signupUser(username: username, email: email, password: password)

    }
    
    @IBAction func dismissErrorView(_ sender: Any) {
        Helpers.sharedInstance.hideErrorMessageAlertDialog(errorView: errorView, navController: navigationController!)
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
            let dbReference = FIRDatabase.database().reference(fromURL: BASE_URL).child(USERS_TABLE).child(uid)
            let newUser = ["username": username, "email": email, "createdAt": Date().timeIntervalSince1970] as [String : Any]
            dbReference.updateChildValues(newUser, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print("signup user error: \(String(describing: err))")
                    return
                }
                
                print("Saved user successfully into DB")
                //TTFirebaseClient.saveCurrentUser()
                
                TTFirebaseClient.saveCurrentUser(success: { (flag: Bool) in
                    UserDefaults.standard.set(email, forKey: "currentLoggedInUserEmail")
                    UserDefaults.standard.synchronize()
                    Helpers.sharedInstance.hideErrorMessageAlertDialog(errorView: self.errorView, navController: self.navigationController!)
                    
                    let profileStoryboard = UIStoryboard(name: "ProfileStoryboard", bundle: nil)
                    let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "SettingsView") as! TTProfilesViewController
                    self.navigationController?.pushViewController(profileVC, animated: true)
//                    self.present(profileVC, animated: true, completion: nil)
                }, failure: { (error: NSError) in
                    
                })
                
                
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
        leftPaddingView.frame = CGRect(x:0, y:0, width:35, height:20)
        leftImgView.frame = CGRect(x:8, y:0, width: 20, height:18)
        usernameTextField.leftView = leftPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        
        
        let emailLeftImgView = UIImageView()
        emailLeftImgView.image = UIImage(named: "envelope")
        emailLeftImgView.contentMode = UIViewContentMode.scaleAspectFit
        let emailLeftPaddingView = UIView()
        emailLeftPaddingView.addSubview(emailLeftImgView)
        emailLeftPaddingView.frame = CGRect(x:0, y:0, width:35, height:20)
        emailLeftImgView.frame = CGRect(x:8, y:0, width: 20, height:18)
        emailTextField.leftView = emailLeftPaddingView
        emailTextField.leftViewMode = UITextFieldViewMode.always
        
        
        let pwdLeftImgView = UIImageView()
        pwdLeftImgView.image = UIImage(named: "padlock")
        pwdLeftImgView.contentMode = UIViewContentMode.scaleAspectFit
        let pwdLeftPaddingView = UIView()
        pwdLeftPaddingView.addSubview(pwdLeftImgView)
        pwdLeftPaddingView.frame = CGRect(x:0, y:0, width:35, height:20)
        pwdLeftImgView.frame = CGRect(x:8, y:0, width: 20, height:18)
        passwordTextField.leftView = pwdLeftPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        
        
        let confirmPwdImgView = UIImageView()
        confirmPwdImgView.image = UIImage(named: "padlock")
        confirmPwdImgView.contentMode = UIViewContentMode.scaleAspectFit
        let confirmPwdPaddingView = UIView()
        confirmPwdPaddingView.addSubview(confirmPwdImgView)
        confirmPwdPaddingView.frame = CGRect(x:0, y:0, width:35, height:20)
        confirmPwdImgView.frame = CGRect(x:8, y:0, width: 20, height:18)
        confirmPwdTextField.leftView = confirmPwdPaddingView
        confirmPwdTextField.leftViewMode = UITextFieldViewMode.always
        
    }


}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.usernameTextField:
            self.emailTextField.becomeFirstResponder()
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            self.confirmPwdTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
