//
//  EditProfileHeader.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/28/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

protocol EditProfileHeaderDelegate {
    func didPressProfilePictureHeader()
}

class EditProfileHeader: UIView{
    
    var editProfileHeaderDelegate: EditProfileHeaderDelegate!
    private var textFieldLabel = UILabel()
    private var profilePictureContainerView = UIButton()
    private var profilePicture = UIImageView()
    private var profilePictureIcon = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup TextField Label
        textFieldLabel.text = NSLocalizedString("Profile picture", comment: "")
        textFieldLabel.textColor = UIColor.darkGray
        textFieldLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(textFieldLabel)
        
        //Setup Button Container View
        profilePictureContainerView.addTarget(self, action: #selector(self.profileButtonPressed), for: .touchUpInside)
        self.addSubview(profilePictureContainerView)
        
        //Setup User Profile Picture
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = UIColor.lightGray
        profilePictureContainerView.addSubview(profilePicture)
        
        //Setup User Profile Picture Icon
        profilePictureIcon.image = UIImage(named: "edit2")
        profilePictureIcon.contentMode = .scaleAspectFit
        profilePictureIcon.clipsToBounds = true
        profilePictureIcon.backgroundColor = UIColor(white: 0.90, alpha: 1)
        profilePictureContainerView.addSubview(profilePictureIcon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        textFieldLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: 25)
        profilePictureContainerView.frame = CGRect(x: 0, y: 25, width: frame.width, height: 200)
        profilePicture.frame = CGRect(x: 0, y: 12.5, width: 175, height: 175)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePictureIcon.frame = CGRect(x: 140, y: 12.5+140, width: 30, height: 30)
        profilePictureIcon.layer.cornerRadius = profilePictureIcon.frame.width/2
    }
    
    func configure(user: DBUser?){
        if(user?.image != nil){
            profilePicture.sd_setImage(with: URL(string: (user?.image)!), completed: nil)
        }
        else{
            profilePicture.image = nil
        }
    }
    
    func profileButtonPressed(){
        self.editProfileHeaderDelegate.didPressProfilePictureHeader()
    }
}
