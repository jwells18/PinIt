//
//  FollowersHeaderReusableView.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class FollowersHeaderReusableView: UICollectionReusableView{
    
    var followersCountLabel = UILabel()
    var followersLabel = UILabel()
    var profilePicture = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white

        //Setup Followers Count Label
        followersCountLabel = UILabel()
        followersCountLabel.textColor = UIColor.darkGray
        followersCountLabel.font = UIFont.boldSystemFont(ofSize: 60)
        followersCountLabel.numberOfLines = 0
        self.addSubview(followersCountLabel)
        
        //Setup Followers Label
        followersLabel = UILabel()
        followersLabel.textColor = UIColor.lightGray
        followersLabel.font = UIFont.boldSystemFont(ofSize: 26)
        followersLabel.numberOfLines = 1
        self.addSubview(followersLabel)
        
        //Setup Profile Picture Button
        profilePicture = UIButton()
        profilePicture.setTitleColor(UIColor.white, for: .normal)
        profilePicture.titleLabel?.font = UIFont.boldSystemFont(ofSize: 36)
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = UIColor.lightGray
        self.addSubview(profilePicture)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        followersCountLabel.frame = CGRect(x: 15, y: 5, width: frame.width-30, height: 70)
        followersLabel.frame = CGRect(x: 15, y: 5+70, width: frame.width-30, height: 50)
        profilePicture.frame = CGRect(x: frame.width-75-15, y: 5+70+50, width: 75, height: 75)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
    }
    
    func configure(dbUser: DBUser?){
        //Set Following Count Label
        followersCountLabel.text = String(dbUser?.followerCount ?? 0)
        //Setup Following Label
        followersLabel.text =  NSLocalizedString("Followers", comment: "")
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

