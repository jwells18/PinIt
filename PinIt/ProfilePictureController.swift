//
//  ProfilePictureController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/12/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import SDWebImage

class ProfilePictureController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    private var profilePicture: UIButton!
    private var isShowPincode = Bool()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white

        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    func setupNavigationBar(){
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Set Navigation ProfileThumbnailController
        self.title = currentDBUser?.displayName
    }
    
    func setupView(){
        //Setup Profile Picture
        self.setupProfilePicture()
        
        //Setup Buttons
        self.setupButtons()
    }
    
    func setupProfilePicture(){
        //Setup Profile Picture
        profilePicture = UIButton.init(type: .custom)
        profilePicture.frame = CGRect(x: w/2-100, y: (h-navigationHeaderAndStatusbarHeight)/2-100-100, width: 200, height: 200)
        if(currentDBUser?.image != nil){
            profilePicture.sd_setImage(with: URL(string: (currentDBUser?.image)!), for: .normal, completed: nil)
        }
        else{
            profilePicture.setImage(UIImage(named: "profilePicturePlaceholder"), for: .normal)
        }
        profilePicture.imageView?.contentMode = .scaleAspectFill
        profilePicture.contentHorizontalAlignment = .fill
        profilePicture.contentVerticalAlignment = .fill
        profilePicture.backgroundColor = PIColor.faintGray
        //TODO: Implement Pincode - for now, feature is hidden
        //profilePicture.addTarget(self, action: #selector(self.profilePictureButtonPressed), for: .touchUpInside)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        profilePicture.imageView?.contentMode = .scaleAspectFill
        self.view.addSubview(profilePicture)
        
        //Setup Profile Picture Labels
        let profilePictureLabel = UILabel(frame: CGRect(x: 15, y: (h-navigationHeaderAndStatusbarHeight)/2+100-100+40, width: w-30, height: 40))
        profilePictureLabel.text = NSLocalizedString("Open           and tap           for ideas", comment: "")
        profilePictureLabel.textColor = UIColor.lightGray
        profilePictureLabel.textAlignment = .center
        profilePictureLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.view.addSubview(profilePictureLabel)
        
        //Setup Profile Picture Icons
        let pinItIcon = UIImageView(frame: CGRect(x: (w/2)-104, y: 0, width: 40, height: 40))
        pinItIcon.image = UIImage(named:"home")
        pinItIcon.clipsToBounds = true
        pinItIcon.layer.cornerRadius = pinItIcon.frame.width/2
        profilePictureLabel.addSubview(pinItIcon)
        
        let cameraIcon = UIImageView(frame: CGRect(x: (w/2)+7, y: 0, width: 40, height: 40))
        cameraIcon.image = UIImage(named:"camera")
        cameraIcon.clipsToBounds = true
        cameraIcon.layer.cornerRadius = cameraIcon.frame.width/2
        profilePictureLabel.addSubview(cameraIcon)
    }
    
    func setupButtons(){
        //Setup Update Profile Picture Button
        let updateProfilePictureButton = UIButton(frame: CGRect(x: 15, y: h-navigationHeaderAndStatusbarHeight-25-40-10-40, width: w-30, height: 40))
        updateProfilePictureButton.setTitle(NSLocalizedString("Update profile picture", comment: ""), for: .normal)
        updateProfilePictureButton.setTitleColor(UIColor.darkGray, for: .normal)
        updateProfilePictureButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        updateProfilePictureButton.backgroundColor = PIColor.faintGray
        updateProfilePictureButton.layer.cornerRadius = 5
        updateProfilePictureButton.clipsToBounds = true
        updateProfilePictureButton.addTarget(self, action: #selector(self.updateProfilePictureButtonPressed), for: .touchUpInside)
        self.view.addSubview(updateProfilePictureButton)
        
        //Setup Create Pincode Button
        let createPincodeButton = UIButton(frame: CGRect(x: 15, y: h-navigationHeaderAndStatusbarHeight-25-40, width: w-30, height: 40))
        createPincodeButton.setTitle(NSLocalizedString("Create Pincode", comment: ""), for: .normal)
        createPincodeButton.setTitleColor(UIColor.white, for: .normal)
        createPincodeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        createPincodeButton.backgroundColor = PIColor.primary
        createPincodeButton.layer.cornerRadius = 5
        createPincodeButton.clipsToBounds = true
        createPincodeButton.addTarget(self, action: #selector(self.createPincodeButtonPressed), for: .touchUpInside)
        self.view.addSubview(createPincodeButton)
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Button Delegates
    func profilePictureButtonPressed(){
        //Switch Picture and Pincode
        if(isShowPincode){
            isShowPincode = false
            if(currentDBUser?.image != nil){
                profilePicture.sd_setImage(with: URL(string: (currentDBUser?.image)!), for: .normal, completed: nil)
            }
            else{
                profilePicture.setImage(UIImage(named: "profilePicturePlaceholder"), for: .normal)
            }
        }
        else{
            isShowPincode = true
            profilePicture.setImage(UIImage(named: "home"), for: .normal)
        }
    }
    
    func updateProfilePictureButtonPressed(){
        //Show Choose Photo Controller
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.mediaTypes = [kUTTypeImage as String]
        imagePickerVC.allowsEditing = false
        self.present(imagePickerVC, animated: true, completion: nil)
    }
    
    func createPincodeButtonPressed(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    //Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        if(image != nil){
            //Set Profile Picture
            profilePicture.setImage(image, for: .normal)
            //Update in Backend
            let userManager = UserManager()
            userManager.setProfilePicture(image: image!)
        }
    }
}
