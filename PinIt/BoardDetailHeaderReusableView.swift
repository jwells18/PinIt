//
//  BoardDetailHeaderReusableView.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

protocol BoardDetailHeaderDelegate {
    func didPressAddCollaborators()
    func didPressProfilePicture()
}

class BoardDetailHeaderReusableView: UICollectionReusableView{
    
    var headerDelegate: BoardDetailHeaderDelegate!
    var boardNameLabel = UILabel()
    var pinCountLabel = UILabel()
    var profilePicture = UIButton()
    var addCollaboratorsButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup Board Name Label
        boardNameLabel.textColor = UIColor.darkGray
        boardNameLabel.font = UIFont.boldSystemFont(ofSize: 36)
        boardNameLabel.numberOfLines = 1
        self.addSubview(boardNameLabel)
        
        //Setup Pin Count Label
        pinCountLabel.textColor = UIColor.darkGray
        pinCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        pinCountLabel.numberOfLines = 0
        self.addSubview(pinCountLabel)
        
        //Setup Add Collaborators Button
        addCollaboratorsButton.backgroundColor = PIColor.faintGray
        addCollaboratorsButton.setImage(UIImage(named: "add"), for: .normal)
        addCollaboratorsButton.addTarget(self, action: #selector(self.addCollaboratorsButtonPressed), for: .touchUpInside)
        addCollaboratorsButton.isHidden = true
        self.addSubview(addCollaboratorsButton)
        
        //Setup Profile Picture Button
        profilePicture.setTitleColor(UIColor.white, for: .normal)
        profilePicture.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = UIColor.lightGray
        profilePicture.addTarget(self, action: #selector(self.profilePictureButtonPressed), for: .touchUpInside)
        self.addSubview(profilePicture)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        boardNameLabel.frame = CGRect(x: 15, y: 10, width: frame.width-30, height: 45)
        pinCountLabel.frame = CGRect(x: 15, y: 10+45, width: frame.width-30, height: 25)
        addCollaboratorsButton.frame = CGRect(x: frame.width-40-10-40-15, y: 10+45+25+50, width: 40, height: 40)
        addCollaboratorsButton.layer.cornerRadius = addCollaboratorsButton.frame.width/2
        profilePicture.frame = CGRect(x: frame.width-40-15, y: 10+45+25+50, width: 40, height: 40)
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
    }
    
    func configure(dbBoard: DBBoard?, dbPins: Array<DBPin>?, dbUser: DBUser?){
        //Set Header Name Label
        boardNameLabel.text =  dbBoard?.name
        //Set Pin Count Label
        pinCountLabel.text = String(format: "%@ pins", String((dbPins?.count ?? 0)))
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
        //Determine whether to hide Add Collaborators
        if(dbBoard?.createdBy == currentDBUser?.objectId){
            addCollaboratorsButton.isHidden = false
        }
        else{
            addCollaboratorsButton.isHidden = true
        }
    }
    
    //Delegates
    func addCollaboratorsButtonPressed(){
        headerDelegate.didPressAddCollaborators()
    }
    
    func profilePictureButtonPressed(){
        headerDelegate.didPressProfilePicture()
    }
}
