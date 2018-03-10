//
//  PIPeopleFollowCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

protocol PeopleFollowCellDelegate{
    func didPressPeopleFollow(sender: UIButton)
}

class PIPeopleFollowCell :UICollectionViewCell{

    var peopleFollowCellDelegate: PeopleFollowCellDelegate!
    private var profilePicture = UIButton()
    private var nameLabel = UILabel()
    private var emptyLabel = UILabel()
    var followButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        backgroundColor = UIColor.white
        
        //Setup ImageView
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = PIColor.faintGray
        profilePicture.isUserInteractionEnabled = false
        profilePicture.imageView?.contentMode = .scaleAspectFill
        profilePicture.contentHorizontalAlignment = .fill
        profilePicture.contentVerticalAlignment = .fill
        self.addSubview(profilePicture)
        
        //Setup Name Label
        nameLabel.textColor = UIColor.darkGray
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        self.addSubview(nameLabel)
        
        //Setup Follow Button
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        followButton.addTarget(self, action: #selector(self.followButtonPressed), for: .touchUpInside)
        self.addSubview(followButton)
        
        //Setup Empty Label
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        profilePicture.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        nameLabel.frame = CGRect(x: 0, y: frame.size.width+5, width: frame.size.width, height: 26)
        followButton.frame = CGRect(x: 0, y: frame.size.width+5+26+10, width: frame.size.width, height: 30)
        emptyLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func configure(dbUser: DBUser?, isFollowing: Bool?){
        self.backgroundView = nil
        profilePicture.isHidden = false
        nameLabel.isHidden = false
        followButton.isHidden = false
        
        nameLabel.text = dbUser?.displayName ?? ""
        if(dbUser?.image != nil){
            //If user has thumbnail, set thumbnail with image
            profilePicture.sd_setImage(with: URL(string: (dbUser?.image)!), for: .normal, completed: nil)
        }
        else{
            //If user does not have thumbnail, default to first letter of name
            if(dbUser?.displayName != nil){
                let displayName = dbUser?.displayName
                let index = displayName?.index((displayName?.startIndex)!, offsetBy: 1)
                let firstLetter = displayName?.substring(to: index!)
                profilePicture.setTitle(firstLetter, for: .normal)
            }
        }
        
        if isFollowing!{
            followButton.backgroundColor = PIColor.faintGray
            followButton.setTitle("Unfollow", for: .normal)
            followButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
        else{
            followButton.backgroundColor = PIColor.primary
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func configureEmpty(showLabel: Bool, text: String?){
        //Show Empty Label
        profilePicture.isHidden = true
        nameLabel.isHidden = true
        followButton.isHidden = true
        
        emptyLabel.text = text
        if(showLabel == true){
            self.backgroundView = emptyLabel
        }
        else{
            //Remove Empty Label (if necessary)
            self.backgroundView = nil
        }
    }
    
    //Button Delegates
    func followButtonPressed(sender:UIButton){
        peopleFollowCellDelegate.didPressPeopleFollow(sender: sender)
    }
}
