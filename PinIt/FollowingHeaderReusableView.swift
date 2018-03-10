//
//  FollowingHeaderReusableView.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import TTSegmentedControl

class FollowingHeaderReusableView: UICollectionReusableView{
    
    var followingCountLabel = UILabel()
    var followingLabel = UILabel()
    var profilePicture = UIButton()
    var segmentedControl = TTSegmentedControl()
    private var segmentedSectionTitles = ["People", "Boards", "Topics"];
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        //Setup Following Count Label
        followingCountLabel = UILabel()
        followingCountLabel.textColor = UIColor.darkGray
        followingCountLabel.font = UIFont.boldSystemFont(ofSize: 60)
        followingCountLabel.numberOfLines = 0
        self.addSubview(followingCountLabel)
        
        //Setup Following Label
        followingLabel = UILabel()
        followingLabel.textColor = UIColor.lightGray
        followingLabel.font = UIFont.boldSystemFont(ofSize: 26)
        followingLabel.numberOfLines = 1
        self.addSubview(followingLabel)
        
        //Setup Profile Picture Button
        profilePicture = UIButton()
        profilePicture.setTitleColor(UIColor.white, for: .normal)
        profilePicture.titleLabel?.font = UIFont.boldSystemFont(ofSize: 36)
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = UIColor.lightGray
        self.addSubview(profilePicture)

        //Setup SegmentedControl
        segmentedControl.itemTitles = segmentedSectionTitles
        segmentedControl.containerBackgroundColor = PIColor.faintGray
        segmentedControl.thumbColor = UIColor.white
        segmentedControl.defaultTextColor = UIColor.darkGray
        segmentedControl.selectedTextColor = UIColor.darkGray
        segmentedControl.defaultTextFont = UIFont.boldSystemFont(ofSize: 14)
        segmentedControl.selectedTextFont = UIFont.boldSystemFont(ofSize: 14)
        segmentedControl.allowChangeThumbWidth = false
        segmentedControl.useGradient = false
        segmentedControl.cornerRadius = 0
        segmentedControl.useShadow = false
        self.addSubview(segmentedControl)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        followingCountLabel.frame = CGRect(x: 15, y: 5, width: frame.width-30, height: 70)
        followingLabel.frame = CGRect(x: 15, y: 5+70, width: frame.width-30, height: 50)
        profilePicture.frame = CGRect(x: frame.width-75-15, y: 5+70+50, width: 75, height: 75)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        segmentedControl.frame = CGRect(x: 15, y: 5+70+60+75+10, width: frame.width-30, height: 34)
    }
    
    func configure(dbUser: DBUser?){
        //Set Following Count Label
        followingCountLabel.text = String(dbUser?.followingCount ?? 0)
        //Set Following Label
        followingLabel.text =  NSLocalizedString("Following", comment: "")
        //Set ProfilePicture Image
        if(dbUser?.image != nil){
            //If user has thumbnail, set thumbnail with image
            profilePicture.sd_setImage(with: URL(string: (dbUser?.image)!), for: .normal, completed: nil)
        }
        else{
            //If user does not have thumbnail, default to first letter of name
            if(!(dbUser?.displayName?.isEmpty)!){
                let displayName = dbUser?.displayName
                let index = displayName?.index((displayName?.startIndex)!, offsetBy: 1)
                let firstLetter = displayName?.substring(to: index!)
                profilePicture.setTitle(firstLetter, for: .normal)
            }
        }
    }
}
