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

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet var errorView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
        setupTextfields()

        emailTextfield.becomeFirstResponder()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self

    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
//    }

    func setupLoginButton() {
        loginButton.layer.cornerRadius = 3.5
    }

    func setupTextfields() {
        let leftImgView = UIImageView()
        leftImgView.image = UIImage(named: "envelope")
        leftImgView.contentMode = UIViewContentMode.scaleAspectFit
        let leftPaddingView = UIView()
        leftPaddingView.addSubview(leftImgView)
        leftPaddingView.frame = CGRect(x:0, y:0, width:35, height:20)
        leftImgView.frame = CGRect(x:8, y:0, width: 20, height:18)
        emailTextfield.leftView = leftPaddingView
        emailTextfield.leftViewMode = UITextFieldViewMode.always


        let leftPwdImgView = UIImageView()
        leftPwdImgView.image = UIImage(named: "padlock")
        leftPwdImgView.contentMode = UIViewContentMode.scaleAspectFit
        let pwdPaddingView = UIView()
        pwdPaddingView.addSubview(leftPwdImgView)
        pwdPaddingView.frame = CGRect(x:0, y:0, width:35, height:20)
        leftPwdImgView.frame = CGRect(x:8, y:0, width: 20, height:18)
        passwordTextfield.leftView = pwdPaddingView
        passwordTextfield.leftViewMode = UITextFieldViewMode.always
    }


    @IBAction func loginUserClicked(_ sender: Any) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text else {
            print("Please enter valid login information")
            return
        }
        loginUserWith(email: email, password: password)

    }

    @IBAction func dismissErrorView(_ sender: Any) {
        Helpers.sharedInstance.hideErrorMessageAlertDialog(errorView: errorView, navController: navigationController!)
    }
    
    func loginUserWith(email: String, password: String) {
        if email.isEmpty || password.isEmpty {
            Helpers.sharedInstance.showErrorMessageAlertDialog("Please enter a valid email or password", errorView: errorView, errorLabel: errorMessageLabel, parentView: view, navController: navigationController!)
            return
        }

        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print("Login user error: \(String(describing: error))")
                Helpers.sharedInstance.showErrorMessageAlertDialog("Please enter a valid email or password", errorView: self.errorView, errorLabel: self.errorMessageLabel, parentView: self.view, navController: self.navigationController!)
                return
            }
            
//            TTFirebaseClient.saveCurrentUser()
            TTFirebaseClient.saveCurrentUser(success: { (flag: Bool) in
           Helpers.sharedInstance.hideErrorMessageAlertDialog(errorView: self.errorView, navController: self.navigationController!)
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.synchronize()
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "MainPageTabBarController") as! UITabBarController
                self.present(homeVC, animated: true, completion: nil)
            }, failure: { (error: NSError) in
                
            })
            
        })
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextfield:
            self.passwordTextfield.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
