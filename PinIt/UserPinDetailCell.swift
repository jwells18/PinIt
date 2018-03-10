//
//  UserPinDetailCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/1/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

protocol UserPinDetailCellDelegate {
    func relayDidPressUserDetail()
}


class UserPinDetailCell: UICollectionViewCell{
    
    var userPinDetailCellDelegate: UserPinDetailCellDelegate!
    private var profilePicture = UIButton()
    private var saveLabel = UILabel()
    private let separatorLine = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        //Setup ImageView
        profilePicture.clipsToBounds = true
        profilePicture.setImage(UIImage(named: "profilePicturePlaceholder"), for: .normal)
        profilePicture.addTarget(self, action: #selector(self.profilePicturePressed), for: .touchUpInside)
        self.addSubview(profilePicture)
        
        //Setup Text Label
        saveLabel.textColor = UIColor.darkGray
        saveLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(saveLabel)
        
        //Add Gray Line Separator
        separatorLine.backgroundColor = PIColor.faintGray.cgColor
        self.layer.addSublayer(separatorLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set ImageView Frame
        profilePicture.frame = CGRect(x: 0, y: 10, width: 40, height: 40)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        //Set UploadedBy Label Frame
        saveLabel.frame = CGRect(x: 40+15, y: 10, width: frame.width-40-15, height: 40)
        separatorLine.frame = CGRect(x: 0, y: frame.height-0.5, width: frame.width, height: 0.5)
    }
    
    func configure(pin: DBPin){
        //Set Image Height
        let userManager = UserManager()
        userManager.downloadUser(uid: pin.createdBy) { (user: DBUser?, isFollowing: Bool?, rawData: NSDictionary?) in
            if(user?.image != nil){
                self.profilePicture.sd_setImage(with: URL(string: (user?.image)!), for: .normal, completed: nil)
            }
            else{
                self.profilePicture.setImage(UIImage(named: "profilePicturePlaceholder"), for: .normal)
            }
            self.saveLabel.text = user?.displayName
        }
    }
    
    func profilePicturePressed(){
        self.userPinDetailCellDelegate.relayDidPressUserDetail()
    }
}
