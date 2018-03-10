//
//  PIPinDetailCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/19/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import UIKit
import CHTCollectionViewWaterfallLayout

protocol PIPinDetailCellDelegate {
    func didPressAddPhotoOrNote()
    func didPressAddComment()
    func didPressUserDetail()
}

class PIPinDetailCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, TriedPinCellDelegate, UserPinDetailCellDelegate{
    
    var pinDetailDelegate: PIPinDetailCellDelegate!
    private let mainCellIdentifier = "mainCell"
    private let triedCellIdentifier = "triedCell"
    private let userDetailCellIdentifier = "saveDetailCell"
    private let addCommentCellIdentifier = "addCommentCell"
    private let defaultCellIdentifier = "defaultCell"
    var pin: DBPin!
    var pullAction: ((_ offset : CGPoint) -> Void)?
    var tappedAction: (() -> Void)?
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Setup CollectionView
        collectionView.register(PIPinDetailMainCell.self, forCellWithReuseIdentifier: mainCellIdentifier)
        collectionView.register(TriedPinCell.self, forCellWithReuseIdentifier: triedCellIdentifier)
        collectionView.register(UserPinDetailCell.self, forCellWithReuseIdentifier: userDetailCellIdentifier)
        collectionView.register(AddCommentCell.self, forCellWithReuseIdentifier: addCommentCellIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: defaultCellIdentifier)
        self.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        collectionView.frame = CGRect(x: 15, y: 0, width: frame.width-30, height: frame.height)
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        collectionView.reloadData()
    }
    
    //MARK: CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int{
        
        return 1
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        
        switch indexPath.row {
        case 0:
            let imageHeight = collectionView.frame.width*CGFloat((pin.imageHeight/pin.imageWidth))+60
            return CGSize(width: collectionView.frame.width, height: imageHeight)
        case 1:
            return CGSize(width: collectionView.frame.width, height: 116)
        case 2:
            return CGSize(width: collectionView.frame.width, height: 60)
        case 3:
            return CGSize(width: collectionView.frame.width, height: 40)
        default:
            return CGSize.zero
        }
    }
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsets.zero
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch(indexPath.row){
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainCellIdentifier, for: indexPath) as! PIPinDetailMainCell
            cell.configure(pin: pin)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: triedCellIdentifier, for: indexPath) as! TriedPinCell
            cell.triedPinCellDelegate = self
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userDetailCellIdentifier, for: indexPath) as! UserPinDetailCell
            cell.userPinDetailCellDelegate = self
            cell.configure(pin: pin)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addCommentCellIdentifier, for: indexPath) as! AddCommentCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedAction?()
        if(indexPath.item == 3){
            pinDetailDelegate.didPressAddComment()
        }
    }
    
    //ScrollView Delegates
    func scrollViewWillBeginDecelerating(_ scrollView : UIScrollView){
        if scrollView.contentOffset.y < navigationHeight{
            pullAction?(scrollView.contentOffset)
        }
    }

    //Tried Pin Delegate
    func relayDidPressAddPhotoOrNote() {
        pinDetailDelegate.didPressAddPhotoOrNote()
    }
    
    //User Pin Detail Delegate
    func relayDidPressUserDetail(){
        pinDetailDelegate.didPressUserDetail()
    }
}
