//
//  EditProfileController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/13/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import STPopup
import IHKeyboardAvoiding
import RealmSwift
import MobileCoreServices

class EditProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, EditProfilePicturePopupDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditProfileHeaderDelegate{
    
    private var tableView = UITableView()
    private var tableViewHeader = EditProfileHeader()
    private var cellIdentifier = "cell"
    private var inputCellTitles = [NSLocalizedString("Name", comment: ""), NSLocalizedString("Username", comment: ""), NSLocalizedString("About you", comment: ""), NSLocalizedString("Location", comment: ""), NSLocalizedString("Website", comment: "")]
    private var userManager = UserManager()
    private var user: DBUser?
    private var displayName: String?
    private var username: String?
    private var about: String?
    private var location: String?
    private var website: String?
    private var profilePicture = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Keyboard Avoiding for textfields
        KeyboardAvoiding.avoidingView = self.view
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download Data
        self.setUserData()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Show Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Edit Profile", comment: "")
        
        //Setup Navigation Items
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(EditProfileController.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //Download Data
    func setUserData(){
        user = currentDBUser
        //Set User Data
        displayName = self.user?.displayName
        username = self.user?.username
        about = self.user?.about
        location = self.user?.location
        website = self.user?.website
        self.tableView.reloadData()
    }
    
    //Setup View
    func setupView(){
        //Setup TableView
        self.setupTableView()
    }
    
    func setupTableView(){
        //Setup TableView
        tableView = UITableView(frame: CGRect(x:15, y:0, width:w-30, height:h-navigationHeaderAndStatusbarHeight))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = PIColor.faintGray
        tableView.register(PIInputCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        
        //Setup TableView Header
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 250)
        tableViewHeader.editProfileHeaderDelegate = self
        tableViewHeader.configure(user: user)
        tableView.tableHeaderView = tableViewHeader
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputCellTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PIInputCell
        cell.selectionStyle = .none
        cell.textFieldLabel.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: 20)
        cell.textFieldLabel.text = inputCellTitles[indexPath.row]
        cell.textField.textColor = UIColor.darkGray
        cell.textField.tintColor = PIColor.primary
        cell.textField.frame = CGRect(x: 0, y: 20, width: cell.frame.width, height: 75)
        cell.textField.placeholder = NSLocalizedString("Add", comment: "")
        cell.textField.font = UIFont.boldSystemFont(ofSize: 22)
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        
        switch(indexPath.row){
        case 0:
            //Name
            cell.textField.text = displayName
            break
        case 1:
            //Username
            cell.textField.text = username
            break
        case 2:
            //About You
            cell.textField.text = about
            break
        case 3:
            //Location
            cell.textField.text = location
            break
        case 4:
            //Website
            cell.textField.text = website
            break
        default:
            break
        }
        
        return cell
    }
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
    //BarButtonItem Delegates
    func backButtonPressed(){
        //Check if User has changed data and update database
        self.checkDataForChanges()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func checkDataForChanges(){
        if((displayName != user?.displayName) || (username != user?.username) || (about != user?.about) || (location != user?.location) || (website != user?.website) ){
            //Update Realm (in case there is delay uploading to backend)
            let realm = try! Realm()
            let dbUser = currentDBUser
            try! realm.write {
                dbUser?.displayName = displayName
                dbUser?.username = username
                dbUser?.about = about
                dbUser?.location = location
                dbUser?.website = website
            }
            //Update Data in Backend
            let updatedUser = User()
            updatedUser.displayName = displayName
            updatedUser.username = username
            updatedUser.about = about
            updatedUser.location = location
            updatedUser.website = website
            userManager.create(user: updatedUser, completionHandler: { (completed: Bool) in
                if(completed){
                    //Show Upload Message
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Saved!", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
                else{
                    //Show Error Message
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Error updating profile", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
            })
        }
    }
    
    //TextField Delegates
    func textFieldDidChange(textField: UITextField) {
        switch textField.tag{
        case 0:
            //Display Name
            displayName = textField.text!
            break
        case 1:
            //Username
            username = textField.text!
            break
        case 2:
            //About
            about = textField.text!
            break
        case 3:
            //Location
            location = textField.text!
            break
        case 4:
            //Website
            website = textField.text!
            break
        default:
            break
        }
    }
    

    //TableView Header Delegate
    func didPressProfilePictureHeader() {
        let popupVC = EditProfilePicturePopupController()
        popupVC.editProfilePicturePopupDelegate = self
        popupVC.contentSizeInPopup = CGSize(width: w, height: 103)
        let popupController = STPopupController.init(rootViewController: popupVC)
        popupController.style = .bottomSheet
        STPopupNavigationBar.appearance().barTintColor = UIColor.white
        STPopupNavigationBar.appearance().tintColor = UIColor.lightGray
        STPopupNavigationBar.appearance().barStyle = .default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.darkGray]
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
        popupController.present(in: self)
    }
    
    func dismissPopupVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Popup Delegates
    func didPressTakeAPhoto(){
        let cameraVC = CameraController()
        cameraVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    func didPressPickFromCameraRoll(){
        //Show Choose Photo Controller
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.mediaTypes = [kUTTypeImage as String]
        imagePickerVC.allowsEditing = false
        self.present(imagePickerVC, animated: true, completion: nil)
    }
    
    //Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        if(image != nil){
            //Update in Backend
            let userManager = UserManager()
            userManager.setProfilePicture(image: image!)
        }
    }
}
