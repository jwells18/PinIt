//
//  EditPinBoardCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/28/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

class EditPinBoardCell: UITableViewCell{
    
    private var cellDescriptionLabel = UILabel()
    var boardImageView = UIImageView()
    var boardNameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
        self.tintColor = UIColor.darkGray
        
        //Setup TextField Label
        cellDescriptionLabel.text = NSLocalizedString("Board", comment: "")
        cellDescriptionLabel.textColor = UIColor.darkGray
        cellDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(cellDescriptionLabel)
        
        //Setup Board ImageView
        boardImageView.layer.cornerRadius = 5
        boardImageView.clipsToBounds = true
        boardImageView.backgroundColor = PIColor.faintGray
        self.addSubview(boardImageView)
        
        //Setup Board Name Label
        boardNameLabel.textColor = UIColor.darkGray
        boardNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        self.addSubview(boardNameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        cellDescriptionLabel.frame = CGRect(x: 15, y: 0, width: frame.width-30, height: 20)
        boardImageView.frame = CGRect(x: 30, y: 20+15, width: 40, height: 40)
        boardNameLabel.frame = CGRect(x: 30+40+15, y: 20+15, width: frame.width-30-40-30, height: 40)
    }
    
    func configure(dbBoard: DBBoard?){
        if(dbBoard != nil){
            boardNameLabel.text = dbBoard?.name
            if(dbBoard?.images != nil){
                let images = (dbBoard?.images?.components(separatedBy: ","))!
                let image = images.first
                if(image != nil){
                    boardImageView.sd_setImage(with: URL(string: image!), completed: nil)
                    boardImageView.backgroundColor = UIColor.white
                }
                else{
                    //If not board images, set background as gray
                    boardImageView.image = nil
                    boardImageView.backgroundColor = PIColor.faintGray
                }
            }
            else{
                //If not board images, set background as gray
                boardImageView.image = nil
                boardImageView.backgroundColor = PIColor.faintGray
            }
        }
    }
}
