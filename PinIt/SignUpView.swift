//
//  EmailSignUpView.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/15/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class SignUpView: UIView{
    
    var instructionsLabel = UILabel()
    var textField = UITextField()
    var pageLabel = UILabel()
    var progressBar = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Setup Instructions Label
        instructionsLabel = UILabel()
        instructionsLabel.textColor = UIColor.darkGray
        instructionsLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(instructionsLabel)
        
        //Setup TextField 
        textField = PIInputField()
        self.addSubview(textField)
        
        //Setup Progress Bar
        progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.setProgress(0.5, animated: true)
        progressBar.trackTintColor = PIColor.faintGray
        progressBar.tintColor = UIColor.darkGray
        self.addSubview(progressBar)
        
        //Setup Page Label
        pageLabel = UILabel()
        pageLabel.textColor = UIColor.darkGray
        pageLabel.font = UIFont.systemFont(ofSize: 12)
        pageLabel.textAlignment = .right
        self.addSubview(pageLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
