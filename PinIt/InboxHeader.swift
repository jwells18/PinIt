//
//  InboxHeader.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/27/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol InboxHeaderDelegate {
    func relayDidPressNewMessage()
}

class InboxHeader: UIView{
    
    var inboxHeaderDelegate: InboxHeaderDelegate!
    var newMessageButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup Message Button
        newMessageButton.setTitle(NSLocalizedString("New Message", comment: ""), for: .normal)
        newMessageButton.setTitleColor(UIColor.white, for: .normal)
        newMessageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        newMessageButton.backgroundColor = PIColor.primary
        newMessageButton.addTarget(self, action: #selector(self.newMessageButtonPressed), for: .touchUpInside)
        newMessageButton.layer.cornerRadius = 5
        newMessageButton.clipsToBounds = true
        self.addSubview(newMessageButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Message Button
        newMessageButton.frame = CGRect(x:0, y:10, width:frame.width, height:40)
    }
    
    //Button Methods
    func newMessageButtonPressed(){
        inboxHeaderDelegate.relayDidPressNewMessage()
    }
    
}
