//
//  EditPinInputCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/28/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class EditPinInputCell: UITableViewCell{
    
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
        textField.placeholder = NSLocalizedString("Add", comment: "")
        textField.textColor = UIColor.darkGray
        textField.font = UIFont.boldSystemFont(ofSize: 22)
        textField.tintColor = PIColor.primary
        self.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        textFieldLabel.frame = CGRect(x: 15, y: 0, width: frame.width-30, height: 20)
        textField.frame = CGRect(x: 15, y: 20, width: frame.width-30, height: 50)
    }
}
