//
//  PIEditPinController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/27/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import STPopup
import IHKeyboardAvoiding
import RealmSwift

class PIEditPinController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DeletePinPopupDelegate{
    
    private var tableView = UITableView()
    private var tableViewHeader = EditPinHeader()
    private var cellIdentifier = "cell"
    private var inputCellIdentifier = "inputCell"
    private var boardCellIdentifier = "boardCell"
    private var doneBtn: UIButton!
    private var caption: String?
    private var boardId: String?
    private var website: String?
    var pin: DBPin!
    private var board: DBBoard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Keyboard Avoiding for textfields
        KeyboardAvoiding.avoidingView = self.view
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download Data
        self.setPinData()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Edit Pin", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        doneBtn = UIButton.init(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 35)
        doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        doneBtn.addTarget(self, action: #selector(self.doneButtonPressed), for: .touchUpInside)
        doneBtn.backgroundColor = PIColor.primary
        doneBtn.layer.cornerRadius = 2
        doneBtn.clipsToBounds = true
        let doneButton = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = doneButton
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //Download Data
    func setPinData(){
        //Set User Data
        caption = pin?.caption
        boardId = pin?.boardId
        website = pin?.website
        self.tableView.reloadData()
        //Load Board Data
        self.loadBoardData()
    }
    
    func loadBoardData(){
       let boardManager = BoardManager()
        boardManager.downloadBoard(pin: pin) { (board: DBBoard?) in
            self.board = board
            self.tableView.reloadData()
        }
    }
    
    //Setup View
    func setupView(){
        //Setup TapToResign Gesture Recognizer
        self.setupTapToResignGestureRecognizer()
        
        //Setup TableView
        self.setupTableView()
    }
    
    func setupTableView(){
        //Setup TableView
        tableView = UITableView(frame: CGRect(x:0, y:0, width:w, height:h-navigationHeaderAndStatusbarHeight))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = PIColor.faintGray
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(EditPinInputCell.self, forCellReuseIdentifier: inputCellIdentifier)
        tableView.register(EditPinBoardCell.self, forCellReuseIdentifier: boardCellIdentifier)
        self.view.addSubview(tableView)
        
        //Setup TableViewHeader
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 110)
        tableViewHeader.configure(image: nil, dbPin: pin)
        tableView.tableHeaderView = tableViewHeader
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row{
        case 0:
            //Description
            return 75
        case 1:
            //Board
            return 105
        case 2:
            //Webite
            return 75
        case 3:
            //Delete
            return 60
        default:
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            //Description
            let cell = tableView.dequeueReusableCell(withIdentifier: inputCellIdentifier, for: indexPath) as! EditPinInputCell
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row
            cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
            cell.textFieldLabel.text = NSLocalizedString("Description", comment: "")
            cell.textField.text = caption
            return cell
        case 1:
            //Board
            let cell = tableView.dequeueReusableCell(withIdentifier: boardCellIdentifier, for: indexPath) as! EditPinBoardCell
            cell.configure(dbBoard: board)
            return cell
        case 2:
            //Website
            let cell = tableView.dequeueReusableCell(withIdentifier: inputCellIdentifier, for: indexPath) as! EditPinInputCell
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row
            cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
            cell.textFieldLabel.text = NSLocalizedString("Website", comment: "")
            cell.textField.text = website
            return cell
        case 3:
            //Delete
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.text = "Delete"
            cell.textLabel?.textColor = UIColor.lightGray
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        }
    }
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch indexPath.row{
        case 1:
            //Show Select Board
            //Show Feature Unavailable
            self.present(featureUnavailableAlert(), animated: true, completion: nil)
            break
        case 3:
            //Show Delete Popup
            self.showDeletePopup()
            break
        default:
            break
        }
    }
    
    //BarButtonItem Delegates
    func backButtonPressed(){
        //Check if User has changed data and update database
        self.checkDataForChanges()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Setup Tap to Resign Gesture Recognizer
    func setupTapToResignGestureRecognizer(){
        let tapToResignGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.resignTextFields))
        tapToResignGestureRecognizer.numberOfTapsRequired = 1
        tapToResignGestureRecognizer.numberOfTouchesRequired = 1
        tapToResignGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapToResignGestureRecognizer)
    }
    
    func checkDataForChanges(){
        if((caption != pin?.caption) || (boardId != pin?.boardId) || (website != pin?.website)){
            //Update Realm (in case there is delay uploading to backend)
            let realm = try! Realm()
            try! realm.write {
                pin?.caption = caption
                pin?.boardId = boardId
                pin?.website = website
            }
            //Update Data in Backend
            var pinUpdateDict = Dictionary<String, Any>()
            pinUpdateDict["caption"] = caption
            pinUpdateDict["boardId"] = boardId
            pinUpdateDict["website"] = website
            let pinManager = PinManager()
            pinManager.updatePin(pin: pin, updateDict: pinUpdateDict, completionHandler: { (error: Error?) in
                if(error != nil){
                    //Show Error Message
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Error updating pin", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
                else{
                    //Show Upload Message
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Saved!", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
            })
        }
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed(){
        //Check for Data Changes, then upload if necessary
        self.dismiss(animated: true) { 
            self.checkDataForChanges()
        }
    }

    //TextField Delegates
    func textFieldDidChange(textField: UITextField) {
        switch textField.tag{
        case 0:
            //Display Name
            caption = textField.text!
            break
        case 2:
            //About
            website = textField.text!
            break
        default:
            break
        }
    }
    
    //Gesture Recognizer Delegates
    func resignTextFields(sender: UITapGestureRecognizer){
        if (sender.state == .ended){
            //Resign all textFields
            self.view.endEditing(true)
        }
    }
    
    //Button Delegates
    func showDeletePopup(){
        //Show Delete Popup
        let popupVC = DeletePinPopupController()
        popupVC.deletePinPopupDelegate = self
        popupVC.contentSizeInPopup = CGSize(width: w, height: 255)
        let popupController = STPopupController.init(rootViewController: popupVC)
        popupController.style = .bottomSheet
        popupController.navigationBarHidden = true
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
        popupController.present(in: self)
    }
    
    func dismissPopupVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Popup Delegate
    func didPressDeletePin() {
        self.dismiss(animated: true) { 
            //Delete Pin
            let pinManager = PinManager()
            pinManager.deletePin(pin: self.pin, completionHandler: { (error: Error?) in
                if(error != nil){
                    //Show Error Message
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Error deleting pin", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
                else{
                    //Delete in Realm
                    pinManager.deleteInRealm(dbPin: self.pin)
                    //Show Toast
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Pin Deleted", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
            })
        }
        
    }
}

