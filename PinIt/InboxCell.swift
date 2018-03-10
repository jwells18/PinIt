//
//  InboxCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/12/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell{
    
    private var emptyLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        //Setup Empty TableView Label
        emptyLabel.text = NSLocalizedString("Empty Inbox Table", comment: "")
        emptyLabel.textColor = UIColor.darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        emptyLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func configure(){
        
    }
    
    func configureEmpty(){
        //Show Empty Label
        self.backgroundView = emptyLabel
    }
    
    
}
