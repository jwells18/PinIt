//
//  PIInputCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/16/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class PIInputCell: UITableViewCell{
    
    var textFieldLabel = UILabel()
    var textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        //Setup TextField Label
        textFieldLabel.textColor = UIColor.darkGray
        textFieldLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(textFieldLabel)
        
        //Setup TextField
        self.addSubview(textField)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
