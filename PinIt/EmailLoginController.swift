//
//  EmailLoginController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/14/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Firebase
import AMPopTip
import Toast_Swift

class EmailLoginController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate{
    
    private var keyboardHeight: CGFloat = 0
    private var nextButton: UIButton!
    private var scrollView: UIScrollView!
    private var scrollViewDict1 = ["instructions": NSLocalizedString("What's your email?", comment: ""), "placeholder":NSLocalizedString("Email Address", comment: "")]
    private var scrollViewDict2 = ["instructions": NSLocalizedString("Create a password", comment: ""), "placeholder":NSLocalizedString("Password", comment: "")]
    private var scrollViewDict3 = ["instructions": NSLocalizedString("What's your name?", comment: ""), "placeholder":NSLocalizedString("Full name", comment: "")]
    private var scrollViewDict4 = ["instructions": String(format: "Hi! %@", NSLocalizedString("How old are you?", comment: "")), "placeholder":NSLocalizedString("Age", comment: "")]
    private var scrollViewArray = [[String: String]]()
    private var scrollViewPage = 0
    private var emailView = SignUpView()
    private var passwordView = SignUpView()
    private var fullNameView = SignUpView()
    private var ageView = SignUpView()
    private var emailString = String()
    private var passwordString = String()
    private var fullNameString = String()
    private var ageString = String()
    private var popTip = AMPopTip()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup ScrollView Data
        scrollViewArray = [scrollViewDict1, scrollViewDict2, scrollViewDict3, scrollViewDict4]
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = "Sign Up"
        
        //Setup Navigation Items
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    //Setup View
    func setupView(){
        //Get Keyboard Height
        keyboardHeight = 300;
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        //Setup ScrollView
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: w, height: h-keyboardHeight-5-40-5))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: w*4, height:scrollView.frame.height)
        scrollView.backgroundColor = UIColor.white
        scrollView.isScrollEnabled = false
        self.view.addSubview(scrollView)
        
        //Setup ScrollView Views
        self.setupSignupViews()
    }
    
    func setupSignupViews(){
        var scrollViewIndex = Int(0)
        let scrollViewWidth = Int(scrollView.frame.width)
        let scrollViewHeight = Int(scrollView.frame.height)
        
        for view in scrollViewArray{
            let signupView = SignUpView()
            signupView.frame = CGRect(x: scrollViewWidth*scrollViewIndex, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            
            //Setup Instructions Label
            signupView.instructionsLabel.frame = CGRect(x: 15, y: 0, width: scrollViewWidth-30, height: 40)
            signupView.instructionsLabel.text = view["instructions"]
            
            //Setup TextField
            signupView.textField.frame = CGRect(x: 15, y: 40, width: scrollViewWidth-30, height: 75)
            let placeholder = view["placeholder"]
            signupView.textField.placeholder = placeholder
            signupView.textField.delegate = self
            signupView.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
            
            //Setup Progress Bar
            signupView.progressBar.frame = CGRect(x: 15, y: scrollViewHeight-20, width:scrollViewWidth-30, height: 20)
            signupView.progressBar.transform = signupView.progressBar.transform.scaledBy(x: 1, y: 4)
            signupView.progressBar.layer.cornerRadius = 6
            signupView.progressBar.clipsToBounds = true
            
            //Setup Page Label
            signupView.pageLabel.frame = CGRect(x: 15, y: scrollViewHeight-20-5-20, width:scrollViewWidth-30, height: 20)
            signupView.pageLabel.text = String(format: "%d of %d", Int(scrollViewIndex+1), scrollViewArray.count)

            switch scrollViewIndex{
            case 0:
                //Setup Email View
                signupView.textField.keyboardType = UIKeyboardType.emailAddress
                signupView.textField.autocapitalizationType = .none
                signupView.textField.becomeFirstResponder()
                signupView.progressBar.setProgress(0.25, animated: false);
                emailView = signupView
                scrollView.addSubview(emailView)
                scrollViewIndex += 1
                break
            case 1:
                //Setup Password View
                signupView.textField.keyboardType = UIKeyboardType.default
                signupView.textField.isSecureTextEntry = true
                signupView.progressBar.setProgress(0.5, animated: false);
                passwordView = signupView
                scrollView.addSubview(passwordView)
                scrollViewIndex += 1
                break
            case 2:
                //Setup Full Name View
                signupView.progressBar.setProgress(0.75, animated: false);
                fullNameView = signupView
                scrollView.addSubview(fullNameView)
                scrollViewIndex += 1
                break
            case 3:
                //Setup Age View
                signupView.progressBar.setProgress(1.00, animated: false);
                signupView.textField.keyboardType = UIKeyboardType.numberPad
                ageView = signupView
                scrollView.addSubview(ageView)
                scrollViewIndex += 1
                break
            default:
                _ = self.navigationController?.popViewController(animated: true)
                break
            }
        }
        
        //Setup Next Button
        nextButton = UIButton(frame: CGRect(x: 15, y: h-keyboardHeight-5-40, width: w-30, height: 40))
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.layer.cornerRadius = 5
        nextButton.backgroundColor = PIColor.primary
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        self.view.addSubview(nextButton)
    }
    
    //MARK: BarButtonItem Delegates
    func backButtonPressed(){
        switch scrollViewPage{
        case 0:
            _ = self.navigationController?.popViewController(animated: true)
            break
        case 1:
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width*0, y: 0), animated: true)
            break
        case 2:
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width*1, y: 0), animated: true)
            break
        case 3:
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width*2, y: 0), animated: true)
            break
        default:
            _ = self.navigationController?.popViewController(animated: true)
            break
        }
    }
    
    //Button Delegates
    func nextButtonPressed(){
        //Setup Error PopUp
        popTip = AMPopTip()
        popTip.font = UIFont.systemFont(ofSize: 14)
        popTip.shouldDismissOnTap = true
        popTip.shouldDismissOnTapOutside = true
        popTip.shouldDismissOnSwipeOutside = false
        popTip.edgeMargin = 5
        popTip.offset = 2
        popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        popTip.popoverColor  = PIColor.orange
        
        //Respond to Next Button Pressed
        switch scrollViewPage{
        case 0:
            //Check Email Address
            if(isValidEmail(testStr: emailView.textField.text!)){
                emailString = emailView.textField.text!
                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width*1, y: 0), animated: true)
            }
            else{
                //Show Error Message
                if(popTip.isVisible){
                    popTip.hide()
                }
                popTip.showText(NSLocalizedString("Email Address Error", comment: ""), direction: .down, maxWidth: 200, in: self.view, fromFrame: emailView.textField.frame)
            }
            break
        case 1:
            //Check Password
            if(self.isValidPassword(testStr: passwordView.textField.text!.trimmingCharacters(in: .whitespaces))){
                passwordString = passwordView.textField.text!
                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width*2, y: 0), animated: true)
            }
            else{
                //Show Error Message
                if(popTip.isVisible){
                    popTip.hide()
                }
                if(passwordView.textField.text!.trimmingCharacters(in: .whitespaces) == "password"){
                    popTip.showText(NSLocalizedString("Password Too Simple Error", comment: ""), direction: .down, maxWidth: 200, in: self.view, fromFrame: emailView.textField.frame)
                }
                else{
                    popTip.showText(NSLocalizedString("Password Error", comment: ""), direction: .down, maxWidth: 200, in: self.view, fromFrame: emailView.textField.frame)
                }
            }
            break
        case 2:
            //Check Full Name
            if(self.isValidFullName(testStr: fullNameView.textField.text!)){
                fullNameString = fullNameView.textField.text!
                //Customize Instructions
                ageView.instructionsLabel.text = String(format: "Hi %@! %@", fullNameString,NSLocalizedString("How old are you?", comment: ""))
                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width*3, y: 0), animated: true)
            }
            else{
                //Show Error Message
                if(popTip.isVisible){
                    popTip.hide()
                }
                popTip.showText(NSLocalizedString("Full Name Error", comment: ""), direction: .down, maxWidth: 200, in: self.view, fromFrame: emailView.textField.frame)
            }
            break
        case 3:
            if(!(ageView.textField.text?.isEmpty)! && self.isValidAge(testStr: ageView.textField.text!)){
                ageString = ageView.textField.text!
                self.signUpUser()
            }
            else{
                //Show Error Message
                if(popTip.isVisible){
                    popTip.hide()
                }
                popTip.showText(NSLocalizedString("Email Address Error", comment: ""), direction: .down, maxWidth: 200, in: self.view, fromFrame: emailView.textField.frame)
            }
            break
        default:
            break
        }
    }
    
    func signUpUser(){
        //Sign Up User
        Auth.auth().createUser(withEmail: emailString, password: passwordString) { (user, error) in
            if(error == nil){
                //Create User Object
                let user = User()
                user.displayName = self.fullNameString
                let userManager = UserManager()
                userManager.create(user: user, completionHandler: { (completed: Bool) in
                    
                })
                
                //Go to Welcome - automatically triggered by user state observer
                let toastDict:[String: Any] = ["message": NSLocalizedString("Welcome to PinIt!", comment: "")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
            }
            else{
                //Show Error Message
                var message = NSLocalizedString("Error", comment:"")
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        message = NSLocalizedString("Invalid email", comment:"")
                    case .emailAlreadyInUse:
                        message = NSLocalizedString("Email already in use", comment:"")
                    case .weakPassword:
                        message = NSLocalizedString("Password too weak", comment:"")
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
    
    //Keyboard Delegates
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    //ScrollView Delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = Float(scrollView.frame.width);
        let fractionalPage = Float(scrollView.contentOffset.x) / pageWidth;
        let page = lroundf(fractionalPage)
        scrollViewPage = Int(page)
        
        switch (scrollViewPage){
        case 0:
            emailView.textField.becomeFirstResponder()
            break
        case 1:
            passwordView.textField.becomeFirstResponder()
            break
        case 2:
            fullNameView.textField.becomeFirstResponder()
            break
        case 3:
            ageView.textField.becomeFirstResponder()
            break
        default:
            break
        }
    }
    
    //TextField Delegates
    func textFieldDidChange(textField: UITextField) {
        if(popTip.isVisible){
            popTip.hide()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if(ageView.textField == textField){
            //Prevent Age over three digits
            return newLength <= 3
        }
        
        //Prevent all textFields from having more than 100 characters
        return newLength <= 100
    }
    
    //Validation Methods
    func isValidPassword(testStr:String?) -> Bool {
        if(testStr != "password" && (testStr?.characters.count)! >= 6){
            return true
        }
        else{
            return false
        }
    }
    
    func isValidFullName(testStr:String) -> Bool {
        if((testStr.characters.count) >= 2){
            return true
        }
        else{
            return false
        }
    }
    
    func isValidAge(testStr:String) -> Bool {
        let age = Int(testStr)
        return age! >= 4 || age! <= 125
    }
}
