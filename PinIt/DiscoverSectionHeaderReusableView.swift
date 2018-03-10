//
//  DiscoverSectionHeaderReusableView.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/3/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class DiscoverSectionHeaderReusableView: UICollectionReusableView{
    
    var sectionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup Board Name Label
        sectionLabel.textColor = UIColor.darkGray
        sectionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.addSubview(sectionLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        sectionLabel.frame = CGRect(x: 15, y: 5, width: frame.size.width-30, height: 40)
    }
    
    func configure(string: String?){
        sectionLabel.text = string
    }
    
}


