//
//  PeopleToFollowCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/3/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

protocol PeopleToFollowCellDelegate{
    func relayDidPressFollow(sender: UIButton)
}

class PeopleToFollowCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var peopleToFollowCellDelegate: PeopleToFollowCellDelegate!
    var cellIdentifier = "cell"
    var followButton = UIButton()
    var profilePicture = UIButton()
    var usernameLabel = UILabel()
    var followersLabel = UILabel()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 5
        collectionView.isUserInteractionEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    private var images = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    func setupView() {
        backgroundColor = UIColor.white
        
        //Setup CollectionView
        collectionView.register(PIImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.layer.cornerRadius = 5
        self.addSubview(collectionView)
        
        //Setup Profile Picture
        profilePicture.backgroundColor = PIColor.faintGray
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.borderWidth = 2
        profilePicture.clipsToBounds = true
        profilePicture.isUserInteractionEnabled = false
        self.addSubview(profilePicture)
        
        //Setup Board Name Label
        usernameLabel.textColor = UIColor.darkGray
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        usernameLabel.textAlignment = .left
        self.addSubview(usernameLabel)
        
        //Setup Name Label
        followersLabel.textColor = UIColor.lightGray
        followersLabel.font = UIFont.boldSystemFont(ofSize: 12)
        followersLabel.textAlignment = .left
        self.addSubview(followersLabel)
        
        //Setup Follow Button
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        followButton.addTarget(self, action: #selector(self.followButtonPressed), for: .touchUpInside)
        //TODO: Follow Button hidden until fully implemented
        //self.addSubview(followButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 175)
        profilePicture.frame = CGRect(x: 5, y: collectionView.frame.height-60, width: 65, height: 65)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        usernameLabel.frame = CGRect(x: 0, y: 175+10, width: frame.width-60-5, height: 22)
        followersLabel.frame = CGRect(x: 0, y: 175+10+22, width: frame.width-60-5, height: 14)
        followButton.frame = CGRect(x: frame.width-60, y: 175+10, width: 60, height: 34)
    }
    
    func configure(user: DBUser?, isFollowing: Bool?){
        usernameLabel.text = user?.displayName
        followersLabel.text = String(format: "%@ followers", String(user?.followerCount ?? 0))
        
        if(user?.image != nil){
            //If user has thumbnail, set thumbnail with image
            profilePicture.sd_setImage(with: URL(string: (user?.image)!), for: .normal, completed: nil)
        }
        else{
            //If user does not have thumbnail, default to first letter of name
            if(user?.displayName != nil){
                let displayName = user?.displayName
                let index = displayName?.index((displayName?.startIndex)!, offsetBy: 1)
                let firstLetter = displayName?.substring(to: index!)
                profilePicture.setTitle(firstLetter, for: .normal)
            }
        }
        
        if(user?.images != nil){
            images = (user?.images?.components(separatedBy: ","))!
        }
        else{
            images = []
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
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellWidth = collectionView.frame.width-6
        let cellHeight = collectionView.frame.height
        switch(indexPath.item){
        case 0:
            return CGSize(width: cellWidth*(0.7), height: cellHeight-4)
        case 1:
            return CGSize(width: cellWidth*(0.3), height: (cellHeight-6)/2)
        case 2:
            return CGSize(width: cellWidth*(0.3), height: (cellHeight-6)/2)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Boards CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIImageCell
        cell.imageView.layer.cornerRadius = 0
        if(images.count > 0 && indexPath.row <= images.count-1){
            cell.configure(image: images[indexPath.row])
        }
        else{
            cell.configure(image: nil)
        }
        cell.backgroundColor = PIColor.faintGray
        return cell
    }
    
    //Button Delegates
    func followButtonPressed(sender:UIButton){
        peopleToFollowCellDelegate.relayDidPressFollow(sender: sender)
    }
}

