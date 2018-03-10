//
//  ProfileHeaderReusableView.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/12/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import PinterestSegment
import SDWebImage

protocol ProfileHeaderDelegate {
    func didPressProfilePicture()
    func didPressFollowersSection()
    func didPressFollowingSection()
    func segmentedControlValueChanged(index: Int)
}

class ProfileHeaderReusableView: UICollectionReusableView{
    
    var headerDelegate: ProfileHeaderDelegate!
    var userLabel = UILabel()
    var profilePicture = UIButton()
    var followersCountButton = UIButton()
    var followersButton = UIButton()
    var followingCountButton = UIButton()
    var followingButton = UIButton()
    var websiteLabel = UILabel()
    var aboutLabel = UILabel()
    var segmentedControl: PinterestSegment!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup User Label
        userLabel.textColor = UIColor.darkGray
        userLabel.font = UIFont.boldSystemFont(ofSize: 30)
        userLabel.numberOfLines = 0
        self.addSubview(userLabel)
        
        //Setup User Thumbnail
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = UIColor.lightGray
        profilePicture.setTitleColor(UIColor.white, for: .normal)
        profilePicture.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        profilePicture.addTarget(self, action: #selector (self.profilePicturePressed), for: .touchUpInside)
        self.addSubview(profilePicture)
        
        //Setup Followers Count Button
        followersCountButton.setTitleColor(UIColor.darkGray, for: .normal)
        followersCountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followersCountButton.contentHorizontalAlignment = .left
        followersCountButton.addTarget(self, action: #selector(self.followersButtonPressed), for: .touchUpInside)
        self.addSubview(followersCountButton)
        
        //Setup Followers Button
        followersButton.setTitle(NSLocalizedString("Followers", comment: ""), for: .normal)
        followersButton.setTitleColor(UIColor.lightGray, for: .normal)
        followersButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followersButton.contentHorizontalAlignment = .left
        followersButton.addTarget(self, action: #selector(self.followersButtonPressed), for: .touchUpInside)
        self.addSubview(followersButton)
        
        //Setup Following Count Button
        followingCountButton.setTitleColor(UIColor.darkGray, for: .normal)
        followingCountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followingCountButton.contentHorizontalAlignment = .left
        followingCountButton.addTarget(self, action: #selector(self.followingButtonPressed), for: .touchUpInside)
        self.addSubview(followingCountButton)
        
        //Setup Following Button
        followingButton.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
        followingButton.setTitleColor(UIColor.lightGray, for: .normal)
        followingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followingButton.contentHorizontalAlignment = .left
        followingButton.addTarget(self, action: #selector(self.followingButtonPressed), for: .touchUpInside)
        self.addSubview(followingButton)
        
        //Setup Website Label
        websiteLabel.textColor = UIColor.darkGray
        websiteLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.addSubview(websiteLabel)
        
        //Setup About Label
        aboutLabel.textColor = UIColor.lightGray
        aboutLabel.font = UIFont.boldSystemFont(ofSize: 14)
        aboutLabel.numberOfLines = 2
        self.addSubview(aboutLabel)
        
        //Setup SegmentedControl
        let profileSectionTitles = [NSLocalizedString("Boards", comment: ""), NSLocalizedString("Pins", comment: "")]
        let style = PinterestSegmentStyle()
        segmentedControl = PinterestSegment(frame: CGRect(x: 0, y: 15+100+5+20+2+40+5, width: 200, height: 36), segmentStyle: style, titles: profileSectionTitles)
        segmentedControl.valueChange = { index in
            self.headerDelegate.segmentedControlValueChanged(index: index)
        }
        self.addSubview(segmentedControl)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        userLabel.frame = CGRect(x: 15, y: 15, width: frame.width-15-100-15, height: 100)
        profilePicture.frame = CGRect(x: frame.width-100-15, y: 15, width: 100, height: 100)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        followersCountButton.frame = CGRect(x: 15, y: 15+100+5, width: 100, height: 20)
        followersButton.frame = CGRect(x: 15, y: 15+100+5+20+2, width: 85, height: 20)
        followingCountButton.frame = CGRect(x: 15+85+5, y: 15+100+5, width: 85, height: 20)
        followingButton.frame = CGRect(x: 15+85+5, y: 15+100+5+20+2, width: 85, height: 20)
        websiteLabel.frame = CGRect(x: 15+85+5+85+5, y: 15+100+5, width: frame.width-15-85-5-85-5-15, height: 20)
        aboutLabel.frame = CGRect(x: 15+85+5+85+5, y: 15+100+5+20+2, width: frame.width-15-85-5-85-5-15, height: 40)
    }
    
    func configure(dbUser: DBUser?){
        //Setup User Label
        userLabel.text = dbUser?.displayName
        //Set Following Labels
        followersCountButton.setTitle(String(dbUser?.followerCount ?? 0), for: .normal)
        followingCountButton.setTitle(String(dbUser?.followingCount ?? 0), for: .normal)
        //Set ProfilePicture Image
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
        //Set Website Label
        websiteLabel.text = dbUser?.website
        //Set About Label
        if((dbUser?.location ?? "").isEmpty == false && (dbUser?.about ?? "").isEmpty == false){
            aboutLabel.text = String(format:"%@ / %@",(dbUser?.location)!, (dbUser?.about)!)
        }
        else if((dbUser?.location ?? "").isEmpty == false && (dbUser?.about ?? "").isEmpty == true){
            aboutLabel.text = dbUser?.location
        }
        else{
            aboutLabel.text = dbUser?.about
        }
    }
    
    //Delegates
    func profilePicturePressed(){
        headerDelegate.didPressProfilePicture()
    }
    
    func followersButtonPressed(){
        headerDelegate.didPressFollowersSection()
    }
    
    func followingButtonPressed(){
        headerDelegate.didPressFollowingSection()
    }
}
