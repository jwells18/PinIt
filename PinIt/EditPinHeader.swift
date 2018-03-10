//
//  EditPinHeader.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/28/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class EditPinHeader: UIView{
    
    var pinImageView = UIImageView()
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Setup Pin ImageView
        pinImageView.frame = CGRect(x: 15, y: 15, width: 75, height: 75)
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
