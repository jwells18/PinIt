//
//  LoginHeader.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/28/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol LoginHeaderDelegate {
    func didPressFacebookLogin()
    func didPressGoogleLogin()
}

class LoginHeader: UIView{
    
    var loginHeaderDelegate: LoginHeaderDelegate!
    private var facebookLoginButton = UIButton()
    private var googleLoginButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup Facebook Login Button
        facebookLoginButton.setTitle(String(format: "%@ Facebook", NSLocalizedString("Log in with", comment: "")), for: .normal)
        facebookLoginButton.setTitleColor(UIColor.white, for: .normal)
        facebookLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        facebookLoginButton.backgroundColor = PIColor.facebookBlue
        facebookLoginButton.layer.cornerRadius = 5
        facebookLoginButton.clipsToBounds = true
        facebookLoginButton.addTarget(self, action: #selector(self.facebookLoginButtonPressed), for: .touchUpInside)
        self.addSubview(facebookLoginButton)
        
        //Setup Google Login Button
        googleLoginButton.setTitle(String(format: "%@ Google", NSLocalizedString("Log in with", comment: "")), for: .normal)
        googleLoginButton.setTitleColor(UIColor.white, for: .normal)
        googleLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        googleLoginButton.backgroundColor = PIColor.googleBlue
        googleLoginButton.layer.cornerRadius = 5
        googleLoginButton.clipsToBounds = true
        googleLoginButton.addTarget(self, action: #selector(self.googleLoginButtonPressed), for: .touchUpInside)
        self.addSubview(googleLoginButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        facebookLoginButton.frame = CGRect(x: 0, y: 10, width: frame.width, height: 40)
        googleLoginButton.frame = CGRect(x: 0, y: 10+40+5, width: frame.width, height: 40)
    }
    
    func facebookLoginButtonPressed(){
        self.loginHeaderDelegate.didPressFacebookLogin()
    }
    
    func googleLoginButtonPressed(){
        self.loginHeaderDelegate.didPressGoogleLogin()
    }
}
