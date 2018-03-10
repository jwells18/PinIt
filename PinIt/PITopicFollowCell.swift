//
//  PITopicFollowCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol TopicFollowCellDelegate{
    func didPressTopicFollow(sender: UIButton)
}

class PITopicFollowCell :UICollectionViewCell{

    var topicFollowCellDelegate: TopicFollowCellDelegate!
    var imageView: UIImageView = UIImageView()
    private var followButton = UIButton()
    private var topicLabel = UILabel()
    private var followerLabel = UILabel()
    private var emptyLabel = UILabel()
    
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
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        //Setup Follow Button
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        followButton.addTarget(self, action: #selector(self.followButtonPressed), for: .touchUpInside)
        self.addSubview(followButton)
        
        //Setup Topic Label
        topicLabel.font = UIFont.boldSystemFont(ofSize: 16)
        topicLabel.textColor = UIColor.white
        topicLabel.numberOfLines = 0
        imageView.addSubview(topicLabel)
        
        //Setup Follower Count Label
        followerLabel.font = UIFont.systemFont(ofSize: 14)
        followerLabel.textColor = UIColor.white
        followerLabel.numberOfLines = 0
        imageView.addSubview(followerLabel)
        
        //Setup Empty Label
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        followButton.frame = CGRect(x: 0, y: frame.size.width+10, width: frame.width, height: 30)
        topicLabel.frame = CGRect(x: 15, y: imageView.frame.width-15-16-30, width: imageView.frame.width-30, height: 30)
        followerLabel.frame = CGRect(x: 15, y: imageView.frame.width-15-16, width: imageView.frame.width-30, height: 16)
    }
    
    func configure(indexPath: IndexPath){
        self.backgroundView = nil
        imageView.isHidden = false
        topicLabel.isHidden = false
        followerLabel.isHidden = false
        followButton.isHidden = false
    }
    
    func configureEmpty(showLabel: Bool, text: String?){
        //Show Empty Label
        imageView.isHidden = true
        topicLabel.isHidden = true
        followerLabel.isHidden = true
        followButton.isHidden = true
        
        emptyLabel.text = text
        if(showLabel == true){
            self.backgroundView = emptyLabel
        }
        else{
            self.backgroundView = nil
        }
    }
    
    //Button Delegates
    func followButtonPressed(sender:UIButton){
        topicFollowCellDelegate.didPressTopicFollow(sender: sender)
    }
}
