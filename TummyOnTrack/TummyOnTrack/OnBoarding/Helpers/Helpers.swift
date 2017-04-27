//
//  Helpers.swift
//  TummyOnTrack
//
//  Created by yanze on 4/27/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class Helpers: NSObject {

    static var sharedInstance = Helpers()
    
    func showErrorMessageAlertDialog(_ errorMessage:String, errorView: UIView, errorLabel: UILabel, parentView: UIView) {
        errorView.frame.size.width = parentView.frame.size.width
        errorView.center = parentView.center
        errorView.frame.origin.y = 0
        errorView.alpha = 0
        errorLabel.isHidden = true
        parentView.addSubview(errorView)
        UIView.animate(withDuration: 1) {
            errorView.alpha = 1
            errorView.frame.origin.y = 64
            errorLabel.isHidden = false
            errorLabel.text = errorMessage
        }
    }
    
    func hideErrorMessageAlertDialog(errorView: UIView) {
        UIView.animate(withDuration: 0.4) {
            errorView.alpha = 0
            errorView.frame.origin.y = -64
        }
    }
    
    
}
