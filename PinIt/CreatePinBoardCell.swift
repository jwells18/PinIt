//
//  CreatePinBoardCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/24/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

class CreatePinBoardCell: UITableViewCell{
    
    private var boardImageView = UIImageView()
    private var boardNameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //Setup Cell
        selectionStyle = .none
        
        //Setup ImageView
        boardImageView.layer.cornerRadius = 5
        boardImageView.clipsToBounds = true
        self.addSubview(boardImageView)
        
        //Setup Text Label
        boardNameLabel.textColor = UIColor.darkGray
        boardNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.addSubview(boardNameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set ImageView Frame
        boardImageView.frame = CGRect(x: 0, y: 5, width: 40, height: 40)
        //Set UploadedBy Label Frame
        boardNameLabel.frame = CGRect(x: 40+15, y: 5, width: frame.width-40-10, height: 40)
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
        else{
            //If no board, setup as Create a Board
            boardImageView.image = UIImage(named: "createBoard")
            boardImageView.backgroundColor = UIColor.white
            boardNameLabel.text = NSLocalizedString("Create board", comment: "")
        }
    }
}
