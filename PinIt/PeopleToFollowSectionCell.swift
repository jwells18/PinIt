//
//  PeopleToFollowCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/3/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

protocol PeopleToFollowSectionDelegate{
    func relayDidPressPeopleToFollowCell(indexPath: IndexPath?)
    func didPressFollow(indexPath: IndexPath?)
}

class PeopleToFollowSectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PeopleToFollowCellDelegate{
    
    var peopleToFollowSectionDelegate: PeopleToFollowSectionDelegate!
    var cellIdentifier = "cell"
    var users: [DBUser]!
    var isFollowingArray: [Bool]!
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 15, bottom: 2, right: 15)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        self.backgroundColor = UIColor.white
        
        //Setup CollectionView
        collectionView.register(PeopleToFollowCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.clipsToBounds = true
        collectionView.layer.cornerRadius = 5
        self.addSubview(collectionView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 225)
    }
    
    func configure(dbUsers: [DBUser]?, isFollowing: [Bool]?){
        users = dbUsers
        isFollowingArray = isFollowing
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func configureEmpty(){
        collectionView.isHidden = true
    }
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (users?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 250, height: 221)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Boards CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PeopleToFollowCell
        cell.peopleToFollowCellDelegate = self
        let user = users[indexPath.item]
        let isFollowing = isFollowingArray[indexPath.item]
        cell.configure(user: user, isFollowing: isFollowing)
        return cell
    }
    
    //CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        peopleToFollowSectionDelegate.relayDidPressPeopleToFollowCell(indexPath: indexPath)
    }
    
    //CollectionViewCell Delegate
    func relayDidPressFollow(sender: UIButton){
        let touchPoint = sender.convert(CGPoint.zero, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: touchPoint)
        peopleToFollowSectionDelegate.didPressFollow(indexPath: indexPath)
    }
}
