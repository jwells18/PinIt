//
//  TabBarController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Toast_Swift

class TabBarController: UITabBarController, UITabBarControllerDelegate{
    
    override func viewDidLoad() {
        self.delegate = self
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.tintColor = UIColorFromRGB(0xC92228)
        
        //Remove Gray Hairline
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch(tabBarController.selectedIndex){
        case 0:
            tabBarController.tabBar.tintColor = UIColorFromRGB(0xC92228)
            tabBarController.tabBar.backgroundColor = UIColor.white
            break
        case 1:
            tabBarController.tabBar.tintColor = UIColor.darkGray
            tabBarController.tabBar.backgroundColor = UIColor.init(white: 1, alpha: 0.85)
            break
        case 2:
            tabBarController.tabBar.tintColor = UIColor.darkGray
            tabBarController.tabBar.backgroundColor = UIColor.init(white: 1, alpha: 0.85)
            break
        case 3:
            tabBarController.tabBar.tintColor = UIColor.darkGray
            tabBarController.tabBar.backgroundColor = UIColor.white
            break
        default:
            break
        }
    }
}
