//
//  PIBoardFollowCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol BoardFollowCellDelegate{
    func didPressBoardFollow(sender: UIButton)
}

class PIBoardFollowCell :UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var boardFollowCellDelegate: BoardFollowCellDelegate!
    var cellIdentifier = "cell"
    var followButton = UIButton()
    private var profilePicture = UIImageView()
    private var boardNameLabel = UILabel()
    private var emptyLabel = UILabel()
    private var nameLabel = UILabel()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = false
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 5
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    func setupView() {
        backgroundColor = UIColor.white

        //Setup CollectionView
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.layer.cornerRadius = 5
        self.addSubview(collectionView)
        
        //Setup Profile Picture
        profilePicture.backgroundColor = PIColor.faintGray
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.borderWidth = 2
        profilePicture.image = UIImage(named:"home")
        self.addSubview(profilePicture)
        
        //Setup Board Name Label
        boardNameLabel.textColor = UIColor.darkGray
        boardNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        boardNameLabel.textAlignment = .left
        self.addSubview(boardNameLabel)
        
        //Setup Name Label
        nameLabel.textColor = UIColor.lightGray
        nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        nameLabel.textAlignment = .left
        self.addSubview(nameLabel)
        
        //Setup Follow Button
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        followButton.addTarget(self, action: #selector(self.followButtonPressed), for: .touchUpInside)
        self.addSubview(followButton)
        
        //Setup Empty Label
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
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width)
        profilePicture.frame = CGRect(x: 15, y: frame.size.width-30, width: 35, height: 35)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        boardNameLabel.frame = CGRect(x: 0, y: frame.size.width+15, width: frame.size.width, height: 22)
        nameLabel.frame = CGRect(x: 0, y: frame.size.width+15+22, width: frame.size.width, height: 18)
        followButton.frame = CGRect(x: 0, y: frame.size.width+15+22+18+10, width: frame.size.width, height: 30)
    }
    
    func configure(){
        self.backgroundView = nil
        collectionView.isHidden = false
        profilePicture.isHidden = false
        nameLabel.isHidden = false
        boardNameLabel.isHidden = false
        followButton.isHidden = false
        
        followButton.backgroundColor = PIColor.primary
        followButton.setTitle("Follow", for: .normal)
        nameLabel.text = "PinIt"
        boardNameLabel.text = "Sample Images"
    }
    
    func configureEmpty(showLabel: Bool, text: String?){
        //Show Empty Label
        collectionView.isHidden = true
        profilePicture.isHidden = true
        nameLabel.isHidden = true
        boardNameLabel.isHidden = true
        followButton.isHidden = true
        
        emptyLabel.text = text
        if(showLabel == true){
            self.backgroundView = emptyLabel
        }
        else{
            self.backgroundView = nil
        }
    }
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellWidth = collectionView.frame.width-6
        return CGSize(width: (cellWidth/2), height: (cellWidth/2))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Boards CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPinCell
        cell.configure(image: samplePinImages[indexPath.item % samplePinImages.count]! as UIImage)
        cell.imageView.layer.cornerRadius = 0
        cell.backgroundColor = PIColor.faintGray
        return cell
    }
    
    //Button Delegates
    func followButtonPressed(sender:UIButton){
        boardFollowCellDelegate.didPressBoardFollow(sender: sender)
    }
}
