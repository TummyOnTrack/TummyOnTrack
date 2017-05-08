//
//  TTNavigationControllerDelegate.swift
//  TummyOnTrack
//
//  Created by Davis Wamola on 5/5/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    @IBOutlet weak var navigationController: UINavigationController?
    var interactionController: UIPercentDrivenInteractiveTransition?

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        guard ((fromVC as? TTRewardsViewController) != nil) else {
//            return nil
//        }
//
//        return TTCircleTransitionAnimator()
        return nil
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
