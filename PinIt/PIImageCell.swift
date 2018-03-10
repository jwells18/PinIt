//
//  PIImageCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/23/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

class PIImageCell :UICollectionViewCell, PITansitionWaterfallGridViewProtocol{

    var imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        //Setup ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = PIColor.faintGray
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
    
    func configure(image: String?){
        //Set ImageView Image
        if (image != nil){
            imageView.sd_setImage(with: URL(string: image!), placeholderImage: nil)
        }
        else{
            imageView.image = nil
        }
    }
    
    func snapShotForTransition() -> UIView! {
        let snapShotView = UIImageView(image: self.imageView.image)
        snapShotView.frame = imageView.frame
        return snapShotView
    }
}
