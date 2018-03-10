//
//  LoginFooter.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/2/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol LoginFooterDelegate {
    func didPressShowPassword()
    func didPressForgotPassword()
    func didPressLogin()
}

class LoginFooter: UIView{
    
    var loginFooterDelegate: LoginFooterDelegate!
    var showPasswordIconButton = UIButton()
    var showPasswordButton = UIButton()
    var loginButton = UIButton()
    var forgotPasswordButton = UIButton()
    var loginActivityIndicator = UIActivityIndicatorView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup Show Password Icon Button
        showPasswordIconButton.setImage(UIImage(named: "uncheckedCircle"), for: .normal)
        showPasswordIconButton.backgroundColor = UIColor.white
        showPasswordIconButton.addTarget(self, action: #selector(self.showPasswordButtonPressed), for: .touchUpInside)
        showPasswordIconButton.layer.cornerRadius = showPasswordIconButton.frame.width/2
        showPasswordIconButton.clipsToBounds = true
        self.addSubview(showPasswordIconButton)
        
        //Setup Show Password Button
        showPasswordButton.setTitle(NSLocalizedString("Show password", comment: ""), for: .normal)
        showPasswordButton.setTitleColor(UIColor.lightGray, for: .normal)
        showPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        showPasswordButton.backgroundColor = UIColor.white
        showPasswordButton.addTarget(self, action: #selector(self.showPasswordButtonPressed), for: .touchUpInside)
        self.addSubview(showPasswordButton)
        
        //Setup Login Button
        loginButton.setTitle(NSLocalizedString("Log in", comment: ""), for: .normal)
        loginButton.setTitleColor(UIColor.darkGray, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.backgroundColor = PIColor.faintGray
        loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        loginButton.isEnabled = false
        self.addSubview(loginButton)
        
        //Setup Login ActivityIndicatorView
        loginActivityIndicator.activityIndicatorViewStyle = .white
        loginButton.addSubview(loginActivityIndicator)
        
        //Setup Forgot Password Button
        forgotPasswordButton.setTitle(NSLocalizedString("Forgot Password?", comment: ""), for: .normal)
        forgotPasswordButton.setTitleColor(UIColor.darkGray, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        forgotPasswordButton.backgroundColor = UIColor.white
        forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordButtonPressed), for: .touchUpInside)
        self.addSubview(forgotPasswordButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        showPasswordIconButton.frame = CGRect(x: 0, y: 10, width: 30, height: 30)
        showPasswordButton.frame = CGRect(x: 30+5, y: 10, width: 120, height: 30)
        loginButton.frame = CGRect(x: 0, y: 10+30+10, width: frame.width, height: 40)
        loginActivityIndicator.frame = CGRect(x: loginButton.frame.width-30-5, y: 5, width: 30, height: 30)
        forgotPasswordButton.frame = CGRect(x: 0, y: 10+30+10+40+25, width: frame.width, height: 40)
    }
    
    func showPasswordButtonPressed(){
        self.loginFooterDelegate.didPressShowPassword()
    }
    
    func loginButtonPressed(){
        self.loginFooterDelegate.didPressLogin()
    }
    
    func forgotPasswordButtonPressed(){
        self.loginFooterDelegate.didPressForgotPassword()
    }
}
