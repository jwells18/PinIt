//
//  CreatePinHeader.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/26/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class CreatePinHeader: UIView{
    
    var pinImageView = UIImageView()
    var pinDescriptionTextView = KMPlaceholderTextView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup Pin ImageView
        pinImageView.layer.cornerRadius = 5
        pinImageView.clipsToBounds = true
        self.addSubview(pinImageView)
        
        //Setup Pin Description TextView
        pinDescriptionTextView.placeholder = NSLocalizedString("Add a description", comment: "")
        pinDescriptionTextView.font = UIFont.systemFont(ofSize: 18)
        pinDescriptionTextView.textColor = UIColor.darkGray
        pinDescriptionTextView.tintColor = PIColor.primary
        self.addSubview(pinDescriptionTextView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Setup Pin ImageView
        pinImageView.frame = CGRect(x: 0, y: 10, width: 75, height: 75)
        //Set Pin Description TextView
        pinDescriptionTextView.frame = CGRect(x: 75+5, y: 10, width: frame.width-75-5, height: frame.height-10-10)
    }
    
    func configure(image: UIImage?, dbPin: DBPin?){
        //Setup Pin ImageView
        if(image != nil){
            pinImageView.image = image
        }
        else if(dbPin?.image != nil){
            pinImageView.sd_setImage(with: URL(string: (dbPin?.image)!), completed: nil)
        }
        else{
            pinImageView.image = nil
        }
    }
}
