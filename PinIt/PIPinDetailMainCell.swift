//
//  PIPinDetailMainCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

class PIPinDetailMainCell: UICollectionViewCell{
    private var detailImageView = UIImageView()
    private var uploadedByLabel = UILabel()
    var imageHeight: CGFloat = 0
    private var user: DBUser!
    private let separatorLine = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        //Setup ImageView
        detailImageView.layer.cornerRadius = 5
        detailImageView.clipsToBounds = true
        detailImageView.backgroundColor = PIColor.faintGray
        self.addSubview(detailImageView)
        
        //Setup UploadedBy Label
        uploadedByLabel.textColor = UIColor.darkGray
        uploadedByLabel.font = UIFont.systemFont(ofSize: 14)
        uploadedByLabel.numberOfLines = 0
        self.addSubview(uploadedByLabel)
        
        //Add Gray Line Separator
        separatorLine.backgroundColor = PIColor.faintGray.cgColor
        self.layer.addSublayer(separatorLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        detailImageView.frame = CGRect(x: 0, y: 15, width: frame.width, height: imageHeight)
        uploadedByLabel.frame = CGRect(x: 0, y: 15+imageHeight, width: frame.width, height: 40)
        separatorLine.frame = CGRect(x: 0, y: frame.height-0.5, width: frame.width, height: 0.5)
    }
    
    func configure(pin: DBPin){
        //Set Image Height
        imageHeight = frame.width*CGFloat((pin.imageHeight/pin.imageWidth))
        let userManager = UserManager()
        userManager.downloadUser(uid: pin.createdBy) { (user: DBUser?, isFollowing: Bool?, rawData: NSDictionary?) in
            let uploadedString = String(format: "Uploaded by %@",(user?.displayName)!)
            let attributedString = NSMutableAttributedString(string: uploadedString)
            let boldRange = NSRange(location: 12, length: (user?.displayName.characters.count)!)
            let boldAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)]
            attributedString.addAttributes(boldAttribute, range: boldRange)
            self.uploadedByLabel.attributedText = attributedString
        }
        detailImageView.sd_setImage(with: URL(string: pin.image), completed: nil)
    }
}
