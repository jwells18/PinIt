//
//  DiscoverSectionCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout

protocol DiscoverSectionCellDelegate {
    func didPressDiscoverPinCell(indexPath: IndexPath)
    func didPressPeopleToFollowCell(indexPath: IndexPath)
    func willDisplayDiscoverPinCell(cell: UICollectionViewCell, indexPath: IndexPath)
}

class DiscoverSectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, PeopleToFollowSectionDelegate{
    
    var sectionTitle: String!
    var discoverSectionCellDelegate: DiscoverSectionCellDelegate!
    var peopleToFollowCellIdentifier = "peopleToFollowCell"
    var discoverPinCellIdentifier = "discoverPinCell"
    var headerIdentifer = "header"
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    private var pins: Array<DBPin>!
    private var users: [DBUser]!
    private var isFollowingArray: [Bool]!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        //Setup CollectionView
        collectionView.register(PeopleToFollowSectionCell.self, forCellWithReuseIdentifier: peopleToFollowCellIdentifier)
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: discoverPinCellIdentifier)
        collectionView.register(DiscoverSectionHeaderReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifer)
        self.addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        collectionView.reloadData()
    }
    
    func configure(dbPins: Array<DBPin>?, dbUsers: [DBUser]?, isFollowing: [Bool]?, section: String?){
        pins = dbPins
        users = dbUsers
        isFollowingArray = isFollowing
        sectionTitle = section
        collectionView.reloadData()
    }
    
    //MARK: CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            if((pins?.count ?? 0) > 0){
                return pins.count
            }
            else{
                return 1
            }
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil

        // Create header
        if (kind == CHTCollectionElementKindSectionHeader) {
            // Create Header
            let headerView : DiscoverSectionHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifer, for: indexPath as IndexPath) as! DiscoverSectionHeaderReusableView
            
            switch indexPath.section{
            case 0:
                headerView.configure(string: NSLocalizedString("People to follow", comment: ""))
                break
            case 1:
                headerView.configure(string: String(format: "%@ %@", NSLocalizedString("New in", comment: ""),sectionTitle))
                break
            default:
                break
            }
            
            reusableView = headerView
        }
        
        return reusableView!
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,heightForHeaderInSection section: Int) -> CGFloat{
        switch section{
        case 0:
            if((users?.count ?? 0) > 0){
                return 50
            }
            else{
                return 0
            }
        case 1:
            if((pins?.count ?? 0) > 0){
                return 50
            }
            else{
                return 0
            }
        default:
            return 0
        }
        
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int{
        
        switch section{
        case 0:
            return 1
        case 1:
            if((pins?.count ?? 0) > 0){
                return 2
            }
            else{
                return 1
            }
        default:
            return 1
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        
        switch indexPath.section{
        case 0:
            if((users?.count ?? 0) > 0){
                return CGSize(width: collectionView.frame.width, height: 225)
            }
            else{
                return CGSize.zero
            }
        case 1:
            if((pins?.count ?? 0) > 0){
                //Setup Pins CollectionView
                let pin = pins[indexPath.item]
                let cellWidth = CGFloat((w-45)/2)
                return CGSize(width: cellWidth, height: cellWidth*CGFloat((pin.imageHeight/pin.imageWidth)))
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 200)
            }
        default:
            return CGSize.zero
        }
    }
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        switch section{
        case 0:
            return UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        case 1:
            return UIEdgeInsets(top: 5, left: 15, bottom: 25, right: 15)
        default:
            return UIEdgeInsets.zero
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        switch section{
        case 0:
            return 0
        case 1:
            return 15
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: peopleToFollowCellIdentifier, for: indexPath) as! PeopleToFollowSectionCell
            cell.peopleToFollowSectionDelegate = self
            if((users?.count ?? 0) > 0){
                //Configure People To Follow Cells
                cell.configure(dbUsers: users, isFollowing: isFollowingArray)
            }
            else{
                cell.configureEmpty()
            }
            return cell
        case 1:
            //Setup Pins CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: discoverPinCellIdentifier, for: indexPath) as! PIPinCell
            if((pins?.count ?? 0) > 0){
                //Configure Pin Cells
                let pin = pins[indexPath.item]
                cell.configure(dbPin: pin)
            }
            else{
                cell.configureEmpty(showLabel: false)
            }
            cell.setNeedsLayout()
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: discoverPinCellIdentifier, for: indexPath) as! PIPinCell
            return cell
        }
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            discoverSectionCellDelegate.didPressDiscoverPinCell(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            discoverSectionCellDelegate.willDisplayDiscoverPinCell(cell: cell, indexPath: indexPath)
        }
    }
    
    //CollectionView Header Delegates
    func relayDidPressPeopleToFollowCell(indexPath: IndexPath?) {
        discoverSectionCellDelegate.didPressPeopleToFollowCell(indexPath: indexPath!)
    }
    
    func didPressFollow(indexPath: IndexPath?) {
        //TODO: Follow button pressed
    }
}
