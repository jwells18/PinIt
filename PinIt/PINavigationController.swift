//
//  PINavigationController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/19/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import UIKit
class PINavigationController : UINavigationController{
    override func popViewController(animated: Bool) -> UIViewController{
        //viewWillAppearWithPageIndex
        let childrenCount = self.viewControllers.count
        let toViewController = self.viewControllers[childrenCount-2] as! PIWaterFallViewControllerProtocol
        let toView = toViewController.transitionCollectionView()
        let popedViewController = self.viewControllers[childrenCount-1] as! UICollectionViewController
        let popView  = popedViewController.collectionView!;
        let indexPath = popView.fromPageIndexPath()
        toViewController.viewWillAppearWithPageIndex(indexPath.row)
        toView?.setToIndexPath(indexPath)
        return super.popViewController(animated: animated)!
    }
}
