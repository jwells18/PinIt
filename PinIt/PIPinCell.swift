//
//  PIPinCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/19/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

class PIPinCell :UICollectionViewCell, PITansitionWaterfallGridViewProtocol{
    var image: UIImage?
    var imageView: UIImageView = UIImageView()
    private var emptyLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        //Setup ImageView
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        //Setup Empty Label
        emptyLabel.text = NSLocalizedString("No Pins", comment: "")
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        emptyLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func configure(dbPin: DBPin?){
        //Remove Empty Label (if necessary)
        self.backgroundView = nil
        //Set ImageView image
        imageView.isHidden = false
        if(dbPin?.image != nil){
            imageView.sd_setImage(with: URL(string: (dbPin?.image)!), placeholderImage: nil)
        }
        else{
            imageView.image = nil
        }
    }
    
    func configure(image: UIImage?){
        //Remove Empty Label (if necessary)
        self.backgroundView = nil
        imageView.isHidden = false
        imageView.image = image
    }
    
    func configureEmpty(showLabel: Bool){
        //Show Empty Label
        imageView.isHidden = true
        if(showLabel == true){
            self.backgroundView = emptyLabel
        }
        else{
            //Remove Empty Label (if necessary)
            self.backgroundView = nil
        }
    }
    
    func snapShotForTransition() -> UIView! {
        let snapShotView = UIImageView(image: self.imageView.image)
        snapShotView.frame = imageView.frame
        return snapShotView
    }
}
