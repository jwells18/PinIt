//
//  PINavigationControllerDelegate.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/2/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class PINavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        let fromVCConfromA = (fromVC as? PITransitionProtocol)
        let fromVCConfromB = (fromVC as? PIWaterFallViewControllerProtocol)
        let fromVCConfromC = (fromVC as? PIPinDetailControllerProtocol)
        
        let toVCConfromA = (toVC as? PITransitionProtocol)
        let toVCConfromB = (toVC as? PIWaterFallViewControllerProtocol)
        let toVCConfromC = (toVC as? PIPinDetailControllerProtocol)
        
        var transitionConditionMet = false
        if((operation == .push && toVC.className == "PIPinDetailController") || (operation == .pop && fromVC.className == "PIPinDetailController" && navigationController.viewControllers.last?.className != "UserDetailController")){
            transitionConditionMet = true
        }
        else{
            transitionConditionMet = false
        }
        
        if((transitionConditionMet == true)&&(fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
            (fromVCConfromB != nil && toVCConfromC != nil)||(fromVCConfromC != nil && toVCConfromB != nil))){
            let transition = PITransition()
            transition.presenting = operation == .pop
            return  transition
        }else{
            return nil
        }
    }
}
