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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
        setupTextfields()
        
        navigationController?.navigationBar.barTintColor = .orange
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
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

    func loginUserWith(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print("Login user error: \(String(describing: error))")
                return
            }
            
            UserDefaults.standard.set(email, forKey: "currentLoggedInUserEmail")
            UserDefaults.standard.synchronize()
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.present(homeVC, animated: true, completion: nil)
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
