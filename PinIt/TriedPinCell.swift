//
//  TriedPinCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/23/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol TriedPinCellDelegate {
    func relayDidPressAddPhotoOrNote()
}

class TriedPinCell: UICollectionViewCell{
    
    var triedPinCellDelegate: TriedPinCellDelegate!
    var headerLabel = UILabel()
    var subHeaderLabel = UILabel()
    var addButton = UIButton()
    private let separatorLine = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        //Setup Header Label
        headerLabel.text = NSLocalizedString("Tried this Pin?", comment: "")
        headerLabel.textColor = UIColor.darkGray
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(headerLabel)
        
        //Setup SubHeader Label
        subHeaderLabel.text = NSLocalizedString("Be the first to share how it went", comment: "")
        subHeaderLabel.textColor = UIColor.darkGray
        subHeaderLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(subHeaderLabel)
        
        //Setup Add Button
        addButton.setTitle(NSLocalizedString("Add photo or note", comment: ""), for: .normal)
        addButton.setTitleColor(UIColor.darkGray, for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addButton.backgroundColor = PIColor.faintGray
        addButton.layer.cornerRadius = 5
        addButton.clipsToBounds = true
        addButton.addTarget(self, action: #selector(self.addButtonPressed), for: .touchUpInside)
        self.addSubview(addButton)
        
        //Add Gray Line Separator
        separatorLine.backgroundColor = PIColor.faintGray.cgColor
        self.layer.addSublayer(separatorLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        headerLabel.frame = CGRect(x: 0, y: 15, width: frame.width, height: 20)
        subHeaderLabel.frame = CGRect(x: 0, y: 15+20, width: frame.width, height: 16)
        addButton.frame = CGRect(x: 0, y: 15+20+16+10, width: frame.width, height: 40)
        separatorLine.frame = CGRect(x: 0, y: frame.height-0.5, width: frame.width, height: 0.5)
    }
    
    func addButtonPressed(){
        triedPinCellDelegate.relayDidPressAddPhotoOrNote()
    }
}
