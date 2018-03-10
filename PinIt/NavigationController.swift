//
//  NavigationController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController{
    
    override func viewDidLoad() {
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.tintColor = UIColor.lightGray
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        self.navigationBar.backgroundColor = UIColor.white
    }
}
