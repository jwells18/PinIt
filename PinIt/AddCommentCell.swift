//
//  AddCommentCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/8/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class AddCommentCell: UICollectionViewCell{
    
    private var addCommentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        //Setup Text Label
        addCommentLabel.textColor = UIColor.lightGray
        addCommentLabel.text = NSLocalizedString("Add a comment", comment: "")
        addCommentLabel.textColor = UIColor.lightGray
        addCommentLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(addCommentLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        addCommentLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
    }
}

