//
//  PIBoardCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import DateToolsSwift

protocol PIBoardCellDelegate {
    func didPressFollow(sender: UIButton)
}

class PIBoardCell : UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var boardCellDelegate: PIBoardCellDelegate!
    var cellIdentifier = "cell"
    private var images = [String]()
    private var boardNameLabel = UILabel()
    private var boardDateLabel = UILabel()
    private var emptyLabel = UILabel()
    private var followButton = UIButton()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 5
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        backgroundColor = UIColor.white
        
        //Setup CollectionView
        collectionView.register(PIImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.layer.cornerRadius = 5
        collectionView.clipsToBounds = true
        collectionView.isUserInteractionEnabled = false
        self.addSubview(collectionView)
        
        //Setup Board Name Label
        boardNameLabel.textColor = UIColor.darkGray
        boardNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        self.addSubview(boardNameLabel)
        
        //Setup Board Date Label
        boardDateLabel.textColor = UIColor.lightGray
        boardDateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        self.addSubview(boardDateLabel)
        
        //Setup Follow Button
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(UIColor.white, for: .normal)
        followButton.layer.cornerRadius = 5
        followButton.backgroundColor = PIColor.primary
        followButton.isHidden = true
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followButton.addTarget(self, action: #selector(self.followButtonPressed), for: .touchUpInside)
        //self.addSubview(followButton)
        
        //Setup Empty
        emptyLabel.text = NSLocalizedString("No Boards", comment: "")
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        collectionView.frame = CGRect(x: 0, y: 5, width: frame.width, height: 175)
        boardNameLabel.frame = CGRect(x: 0, y: 5+175+5, width: frame.width-75, height: 40)
        boardDateLabel.frame = CGRect(x: 0, y: 5+175+5+40, width: frame.width-75, height: 16)
        followButton.frame = CGRect(x: frame.width-70, y: 5+175+5+10, width: 70, height: 36)
    }
    
    func configure(board: Board){
        //Remove Empty Label (if necessary)
        self.backgroundView = nil
        //Set Board Labels
        boardNameLabel.text = board.name
        let date = dateFromDouble(double: board.updatedAt)
        boardDateLabel.text = date.timeAgoSinceNow
        if(board.images != nil){
            images = (board.images?.components(separatedBy: ","))!
        }
        else{
            images = []
        }
        if(board.createdBy == currentDBUser?.objectId){
            followButton.isHidden = true
        }
        else{
            followButton.isHidden = false
        }
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
    }
    
    func configure(dbBoard: DBBoard){
        //Remove Empty Label (if necessary)
        self.backgroundView = nil
        //Set Board Labels
        boardNameLabel.text = dbBoard.name
        let date = dateFromDouble(double: dbBoard.updatedAt)
        boardDateLabel.text = date.timeAgoSinceNow
        if(dbBoard.images != nil){
            images = (dbBoard.images?.components(separatedBy: ","))!
        }
        else{
            images = []
        }
        if(dbBoard.createdBy == currentDBUser?.objectId){
            followButton.isHidden = true
        }
        else{
            followButton.isHidden = false
        }
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
    }
    
    func configureEmpty(){
        //Setup Empty View
        collectionView.isHidden = true
        boardNameLabel.isHidden = true
        boardDateLabel.isHidden = true
        followButton.isHidden = true
        self.backgroundView = emptyLabel
    }
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellWidth = collectionView.frame.width-5
        let cellHeight = collectionView.frame.height
        switch(indexPath.item){
        case 0:
            return CGSize(width: cellWidth*(0.45), height: cellHeight-2)
        case 1:
            return CGSize(width: cellWidth*(0.275), height: (cellHeight-3)/2)
        case 2:
            return CGSize(width: cellWidth*(0.275), height: (cellHeight-3)/2)
        case 3:
            return CGSize(width: cellWidth*(0.275), height: (cellHeight-3)*(0.75))
        case 4:
            return CGSize(width: cellWidth*(0.275), height: (cellHeight-3)*(0.25))
        default:
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Boards CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIImageCell
        cell.backgroundColor = PIColor.faintGray
        if(images.count > 0 && indexPath.row <= images.count-1){
            cell.configure(image: images[indexPath.row])
        }
        else{
            cell.configure(image: nil)
        }
        return cell
    }
    
    //Button Delegates
    func followButtonPressed(sender:UIButton){
        boardCellDelegate.didPressFollow(sender: sender)
    }
}
