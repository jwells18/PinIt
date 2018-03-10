//
//  PIInputField.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/16/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class PIInputField: UITextField{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Customize TextField
        self.tintColor = PIColor.primary
        self.font = UIFont.boldSystemFont(ofSize: 30)
        self.autocorrectionType = .no
        self.textColor = UIColor.darkGray
        self.clearButtonMode = .whileEditing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
