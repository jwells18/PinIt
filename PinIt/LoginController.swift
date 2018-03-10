//
//  LoginController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/16/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Firebase
import AMPopTip
import Toast_Swift

class LoginController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LoginHeaderDelegate, LoginFooterDelegate{
    
    private var cellIdentifier = "cell"
    private var tableView = UITableView()
    private var tableViewHeader = LoginHeader()
    private var tableViewFooter = LoginFooter()
    private var popTip = AMPopTip()
    private var isHidePassword = Bool()
    private var emailString = String()
    private var passwordString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        isHidePassword = true
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Log in", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    //Setup View
    func setupView(){
        //Setup TapToResign Gesture Recognizer
        self.setupTapToResignGestureRecognizer()
        
        //Setup TableView
        self.setupTableView()
        
        //Setup Error PopUp
        self.setupErrorPopup()
    }
    
    func setupTapToResignGestureRecognizer(){
        let tapToResignGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.resignTextFields))
        tapToResignGestureRecognizer.numberOfTapsRequired = 1
        tapToResignGestureRecognizer.numberOfTouchesRequired = 1
        tapToResignGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapToResignGestureRecognizer)
    }
    
    func setupTableView(){
        //Setup Notifications TableView
        tableView = UITableView(frame: CGRect(x:15, y:0, width:w-30, height:h))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(PIInputCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        
        //Setup TableView Header
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10+40+5+40+5)
        tableViewHeader.loginHeaderDelegate = self
        tableView.tableHeaderView = tableViewHeader
        
        //Setup TableView Footer
        tableViewFooter.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10+30+10+40+25+40+10)
        tableViewFooter.loginFooterDelegate = self
        tableView.tableFooterView = tableViewFooter
    }
    
    func setupErrorPopup(){
        popTip = AMPopTip()
        popTip.font = UIFont.systemFont(ofSize: 14)
        popTip.shouldDismissOnTap = true
        popTip.shouldDismissOnTapOutside = true
        popTip.shouldDismissOnSwipeOutside = false
        popTip.edgeMargin = 5
        popTip.offset = 2
        popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        popTip.popoverColor  = PIColor.orange
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PIInputCell
        cell.selectionStyle = .none
        cell.textFieldLabel.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: 20)
        cell.textField.frame = CGRect(x: 0, y: 20, width: cell.frame.width, height: 75)
        cell.textField.textColor = UIColor.darkGray
        cell.textField.font = UIFont.boldSystemFont(ofSize: 26)
        cell.textField.tintColor = PIColor.primary
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        switch(indexPath.row){
        case 0:
            cell.textFieldLabel.text = NSLocalizedString("Email", comment: "")
            cell.textField.placeholder = NSLocalizedString("Enter your email", comment: "")
            cell.textField.keyboardType = .emailAddress
            return cell
        case 1:
            cell.textFieldLabel.text = NSLocalizedString("Password", comment: "")
            cell.textField.placeholder = NSLocalizedString("Enter your password", comment: "")
            cell.textField.isSecureTextEntry = isHidePassword
            cell.textField.keyboardType = .default
            return cell
        default:
            return cell
        }
    }
    
    //TextField Delegates
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(textField.placeholder == NSLocalizedString("Enter your email", comment: "") && !(textField.text?.isEmpty)!){
            //Validate Email
            switch(isValidEmail(testStr: textField.text!)){
            case true:
                return true
            case false:
                //Show Error Message
                if(popTip.isVisible){
                    popTip.hide()
                    return true
                }
                else{
                    let indexPath = IndexPath(row: 0, section: 0)
                    let cell = self.tableView.cellForRow(at: indexPath) as! PIInputCell
                    popTip.showText(NSLocalizedString("Email Address Error", comment: ""), direction: .down, maxWidth: 200, in: self.view, fromFrame: cell.frame)
                    return false
                }
            }
        }
        else{
            return true
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(popTip.isVisible){
            popTip.hide()
        }
        
        if(textField.placeholder == NSLocalizedString("Enter your email", comment: "")) {
            emailString = textField.text!
        }
        else if(textField.placeholder == NSLocalizedString("Enter your password", comment: "")){
            passwordString = textField.text!
        }
    
        //Validate Email & Password
        if(self.isValidEmail(testStr: emailString) && passwordString.characters.count >= 6){
            //Enable Login Button
            tableViewFooter.loginButton.isEnabled = true
            tableViewFooter.loginButton.backgroundColor = PIColor.primary
            tableViewFooter.loginButton.setTitleColor(UIColor.white, for: .normal)
        }
        else{
            tableViewFooter.loginButton.isEnabled = false
            tableViewFooter.loginButton.backgroundColor = PIColor.faintGray
            tableViewFooter.loginButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
    }
    
    //Validation Methods
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(testStr:String?) -> Bool {
        if(testStr != "password" && (testStr?.characters.count)! >= 6){
            return true
        }
        else{
            return false
        }
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //TableView Header Delegates
    func didPressFacebookLogin(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressGoogleLogin(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    //TableView Footer Delegates
    func didPressShowPassword() {
        let indexPath = NSIndexPath.init(row: 1, section: 0)
        let cell: PIInputCell = tableView.cellForRow(at: indexPath as IndexPath) as! PIInputCell

        switch(isHidePassword){
        case true:
            isHidePassword = false
            tableViewFooter.showPasswordIconButton.setImage(UIImage(named: "checkedCircle"), for: .normal)
            break
        case false:
            isHidePassword = true
            tableViewFooter.showPasswordIconButton.setImage(UIImage(named: "uncheckedCircle"), for: .normal)
            break
        }

        cell.textField.isSecureTextEntry = isHidePassword
        cell.textField.becomeFirstResponder()
    }
    
    func didPressLogin() {
        tableViewFooter.loginActivityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: emailString, password: passwordString) { (user, error) in
            if(error == nil){
                //Go to Welcome - automatically triggered by user state observer in App Delegate
                self.tableViewFooter.loginActivityIndicator.stopAnimating()
                
                let toastDict:[String: Any] = ["message": NSLocalizedString("Welcome back!", comment: "")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
            }
            else{
                //Show Error Message
                self.tableViewFooter.loginActivityIndicator.stopAnimating()
                
                var message = NSLocalizedString("Error", comment:"")
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        message = NSLocalizedString("Invalid email", comment:"")
                    case .userDisabled:
                        message = NSLocalizedString("Account disabled", comment:"")
                    case .wrongPassword:
                        message = NSLocalizedString("The password you entered is incorrect", comment:"")
                    default:
                        break
                    }
                }
                
                //Show Error Toast
                let toastDict:[String: Any] = ["message": message]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
            }
        }
    }
    
    func didPressForgotPassword() {
        //Show Reset Alert Controller
        let alert = UIAlertController(title: NSLocalizedString("Reset Password", comment:""), message: NSLocalizedString("Enter your email to send a password reset", comment:""), preferredStyle: .alert)
        var emailTextField: UITextField!
        alert.addTextField { (textField : UITextField!) -> Void in
            emailTextField = textField
            textField.placeholder = "Email address"
        }
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { alert -> Void in
            let emailString = emailTextField.text
            
            if(self.isValidEmail(testStr: emailString!)){
                Auth.auth().sendPasswordReset(withEmail: emailString!) { (error) in
                    if((error) != nil){
                        //Show Error Toast
                        let toastDict:[String: Any] = ["message": NSLocalizedString("Error! Try again", comment:"")]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                    }
                    else{
                        //Show Error Toast
                        let toastDict:[String: Any] = ["message": NSLocalizedString("Password Reset sent", comment:"")]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                    }
                }
            }
            else{
                //Show Error Toast
                let toastDict:[String: Any] = ["message": NSLocalizedString("Error! Try again", comment:"")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
            }
        })
        alert.addAction(sendAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Gesture Recognizer Delegates
    func resignTextFields(sender: UITapGestureRecognizer){
        if (sender.state == .ended){
            //Resign all textFields
            self.view.endEditing(true)
        }
    }
}
