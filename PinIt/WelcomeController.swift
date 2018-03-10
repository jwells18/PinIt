//
//  WelcomeController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/12/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class WelcomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    private var cellIdentifier = "cell"
    private var scrollTimer: Timer!
    private var collectionView: UICollectionView!
    private var collectionViewContentOffset = CGPoint()
    private var offset = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup View
        self.view.backgroundColor = UIColor.white
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if(self.view.subviews.contains(collectionView) && !scrollTimer.isValid){
            self.setupAutomaticScrolling()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollTimer.invalidate()
    }
    
    func setupView(){
        //Setup Slideshow Player
        self.setupSlideshowCollectionView()

        //Setup Welcome View
        self.setupWelcomeView()
        
        //Setup Login Buttons
        self.setupLoginButtons()
    }
    
    func setupSlideshowCollectionView(){
        //Setup CollectionView Layout
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        
        //Setup CollectionView
        collectionView = UICollectionView(frame: CGRect(x:15, y:0, width:w-30, height:h/2-40-10-10), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        
        //Add Gradient overlay to bottom of CollectionView
        let gradientView = UIView(frame: collectionView.frame)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.width, height: gradientView.frame.height)
        gradientLayer.colors = [UIColor.init(white: 1, alpha: 0).cgColor, UIColor.white.cgColor]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        self.view.addSubview(gradientView)
        
        //Setup Automatic Scrolling
        self.setupAutomaticScrolling()
    }

    func setupAutomaticScrolling(){
        //Set Initial CollectionView Content Offset
        offset = Double(collectionView.frame.height)
        
        //Setup Scrolling Timer
        scrollTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.scrollCollectionView), userInfo: nil, repeats: true)
        scrollTimer.fire()
    }
    
    func scrollCollectionView(){
        offset = offset+1
        collectionViewContentOffset = CGPoint(x: 0, y: Double(offset));
        collectionView.setContentOffset(collectionViewContentOffset, animated: true)
    }
    
    func setupWelcomeView(){
        //Setup Main Logo
        let mainLogo = UIImageView(frame: CGRect(x: (w-150)/2, y: h/2-20-10-150, width: 150, height: 150))
        mainLogo.backgroundColor = UIColor.white
        mainLogo.layer.borderColor = UIColor.white.cgColor
        mainLogo.layer.borderWidth = 8
        mainLogo.layer.cornerRadius = mainLogo.frame.width/2
        mainLogo.image = UIImage(named: "home")
        self.view.addSubview(mainLogo)
        
        //Setup Main Label
        let mainLabel = UILabel(frame: CGRect(x: 15, y: h/2-20, width: w-30, height: 40))
        mainLabel.text = String(format: "%@ PinIt",NSLocalizedString("Welcome to", comment: ""))
        mainLabel.textColor = UIColor.darkGray
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.boldSystemFont(ofSize: 28)
        self.view.addSubview(mainLabel)
    }
    
    func setupLoginButtons(){
        //Setup Email Login Button
        let emailLoginButton = UIButton(frame: CGRect(x: 15, y: h-75-40-20-40-5-40-5-40, width: w-30, height: 40))
        emailLoginButton.setTitle(String(format:"%@ %@",NSLocalizedString("ContinueWithLogin", comment: ""), NSLocalizedString("Email", comment: "")), for: .normal)
        emailLoginButton.setTitleColor(UIColor.white, for: .normal)
        emailLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        emailLoginButton.backgroundColor = PIColor.primary
        emailLoginButton.layer.cornerRadius = 5
        emailLoginButton.clipsToBounds = true
        emailLoginButton.addTarget(self, action: #selector(self.emailLoginButtonPressed), for: .touchUpInside)
        self.view.addSubview(emailLoginButton)
        
        //Setup Facebook Login Button
        let facebookLoginButton = UIButton(frame: CGRect(x: 15, y: h-75-40-20-40-5-40, width: w-30, height: 40))
        facebookLoginButton.setTitle(String(format: "%@ Facebook", NSLocalizedString("ContinueWithLogin", comment: "")), for: .normal)
        facebookLoginButton.setTitleColor(UIColor.white, for: .normal)
        facebookLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        facebookLoginButton.backgroundColor = PIColor.facebookBlue
        facebookLoginButton.layer.cornerRadius = 5
        facebookLoginButton.clipsToBounds = true
        facebookLoginButton.addTarget(self, action: #selector(self.facebookLoginButtonPressed), for: .touchUpInside)
        self.view.addSubview(facebookLoginButton)
        
        //Setup Google Login Button
        let googleLoginButton = UIButton(frame: CGRect(x: 15, y: h-75-40-20-40, width: w-30, height: 40))
        googleLoginButton.setTitle(String(format: "%@ Google", NSLocalizedString("ContinueWithLogin", comment: "")), for: .normal)
        googleLoginButton.setTitleColor(UIColor.white, for: .normal)
        googleLoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        googleLoginButton.backgroundColor = PIColor.googleBlue
        googleLoginButton.layer.cornerRadius = 5
        googleLoginButton.clipsToBounds = true
        googleLoginButton.addTarget(self, action: #selector(self.googleLoginButtonPressed), for: .touchUpInside)
        self.view.addSubview(googleLoginButton)
        
        //Setup Login Button
        let loginButton = UIButton(frame: CGRect(x: 15, y: h-75-40, width: w-30, height: 40))
        loginButton.setTitle(NSLocalizedString("Log in", comment: ""), for: .normal)
        loginButton.setTitleColor(UIColor.darkGray, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.backgroundColor = PIColor.faintGray
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        loginButton.addTarget(self, action: #selector(self.loginButtonPressed), for: .touchUpInside)
        self.view.addSubview(loginButton)
        
        //Setup Terms & Policy Button
        let termsPolicyButton = UIButton(frame: CGRect(x: 15, y: h-75, width: w-30, height: 75))
        termsPolicyButton.setTitle(NSLocalizedString("TermsPolicyLoginAgreement", comment: ""), for: .normal)
        termsPolicyButton.setTitleColor(UIColor.darkGray, for: .normal)
        termsPolicyButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        termsPolicyButton.titleLabel?.textAlignment = .left
        termsPolicyButton.titleLabel?.numberOfLines = 0
        termsPolicyButton.backgroundColor = UIColor.white
        termsPolicyButton.addTarget(self, action: #selector(self.termsPolicyButtonPressed), for: .touchUpInside)
        self.view.addSubview(termsPolicyButton)
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 802
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Boards CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPinCell
        cell.configure(image: samplePinImages[indexPath.item % samplePinImages.count]! as UIImage)
        return cell
    }
    
    //MARK: Button Delegates
    func emailLoginButtonPressed(){
        //Push to Email Login Controller
        let emailLoginVC = EmailLoginController()
        self.navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    func facebookLoginButtonPressed(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func googleLoginButtonPressed(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func loginButtonPressed(){
        //Show Login Controller
        let loginVC = LoginController()
        let navVC = NavigationController.init(rootViewController: loginVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func termsPolicyButtonPressed(){
        //Show WebView with Terms & Policies
        let webPageVC = PIWebViewController()
        webPageVC.url = NSURL(string: NSLocalizedString("PolicyURL", comment: ""))!
        let navVC = NavigationController.init(rootViewController: webPageVC)
        self.present(navVC, animated: true, completion: nil)
    }
}
