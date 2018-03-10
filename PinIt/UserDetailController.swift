//
//  UserDetailController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/3/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import STPopup
import RealmSwift

class UserDetailController: UIViewController, UICollectionViewDataSource,  UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, ProfileHeaderDelegate, PITransitionProtocol, PIWaterFallViewControllerProtocol, SendPopupDelegate, PIBoardCellDelegate{
    
    var uid = String()
    private var user: DBUser!
    private var boards: [DBBoard]!
    private var pins: [DBPin]!
    private let boardCellIdentifier = "boardCell"
    private let pinCellIdentifier = "pinCell"
    private let headerIdentifier = "header"
    private var segmentedControlCurrentIndex = 0
    private let navigationDelegate = PINavigationControllerDelegate()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width:w, height:h-navigationHeaderAndStatusbarHeight), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    private var refreshControl = UIRefreshControl()
    private var activityIndicator = UIActivityIndicatorView()
    private var isInitialDownload = Bool()
    private var backButton: UIBarButtonItem!
    private var sendBtn: UIButton!
    private var sendButton: UIBarButtonItem!
    private var followBtn: UIButton!
    private var followButton: UIBarButtonItem!
    private var isFollowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.navigationController!.delegate = navigationDelegate
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download User
        self.downloadUser()
        
        //Download Data
        self.isInitialDownload = true
        self.downloadData()

        //Setup View
        self.setupView()
        
        //Add Observer for All Toast Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadData), name: NSNotification.Name(rawValue: refreshProfileVCNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        //Setup Navigation Items
        backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        //Setup Send Button
        sendBtn = UIButton.init(type: .custom)
        sendBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendBtn.setTitleColor(UIColor.darkGray, for: .normal)
        sendBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendBtn.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
        sendBtn.backgroundColor = PIColor.faintGray
        sendBtn.layer.cornerRadius = 2
        sendBtn.clipsToBounds = true
        sendButton = UIBarButtonItem(customView: sendBtn)
        
        //Setup Follow Button
        followBtn = UIButton.init(type: .custom)
        followBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
        followBtn.setTitleColor(UIColor.white, for: .normal)
        followBtn.backgroundColor = PIColor.primary
        followBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followBtn.addTarget(self, action: #selector(self.followButtonPressed), for: .touchUpInside)
        followBtn.layer.cornerRadius = 2
        followBtn.clipsToBounds = true
        followBtn.isEnabled = false
        followButton = UIBarButtonItem(customView: followBtn)
        self.navigationItem.rightBarButtonItems = [followButton, sendButton]
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func updateFollowButton(enabled: Bool, isFollowing: Bool){
        self.followBtn.isEnabled = enabled
        if isFollowing{
            //Update Button
            followBtn.setTitle(NSLocalizedString("Unfollow", comment: ""), for: .normal)
            followBtn.setTitleColor(UIColor.darkGray, for: .normal)
            followBtn.backgroundColor = PIColor.faintGray
        }
        else{
            //Update Button
            followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
            followBtn.setTitleColor(UIColor.white, for: .normal)
            followBtn.backgroundColor = PIColor.primary
        }
    }
    
    func downloadUser(){
        let userManager = UserManager()
        userManager.downloadUser(uid: uid) { (user: DBUser?, isFollowingUser: Bool?, rawData: NSDictionary?) in
            self.user = user
            
            self.isFollowing = isFollowingUser!
            if(user != nil){
                if(user?.objectId != currentDBUser?.objectId){
                    self.updateFollowButton(enabled: true, isFollowing: isFollowingUser!)
                }
                else{
                    self.updateFollowButton(enabled: false, isFollowing: false)
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Download Data
    func downloadData(){
        //Start Activity Indicator
        activityIndicator.startAnimating()
        //Download Board Data
        let boardManager = BoardManager()
        boardManager.downloadBoards(uid: uid, completionHandler: { (boardResults: [DBBoard]?) in
            self.boards = boardResults
            if(self.segmentedControlCurrentIndex == 0){
                self.isInitialDownload = false
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        })
        
        //Download Pin Data
        let pinManager = PinManager()
        pinManager.downloadPins(uid: uid, completionHandler: { (pinResults: [DBPin]?) in
            self.pins = pinResults
            if(self.segmentedControlCurrentIndex == 1){
                self.isInitialDownload = false
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    //Setup View
    func setupView(){
        //Setup CollectionView
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        //Register CollectionView Cells
        collectionView.register(PIBoardCell.self, forCellWithReuseIdentifier: boardCellIdentifier)
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: pinCellIdentifier)
        collectionView.register(ProfileHeaderReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //Setup RefreshControl
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.downloadData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        //Setup ActivityIndicator
        activityIndicator.activityIndicatorViewStyle = .gray
        collectionView.backgroundView = activityIndicator
        
        self.view.addSubview(collectionView)
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch(segmentedControlCurrentIndex) {
        case 0:
            if((boards?.count ?? 0) > 0){
                return boards.count
            }
            else{
                switch isInitialDownload{
                case true:
                    return 0
                case false:
                    return 1
                }
            }
        case 1:
            if((pins?.count ?? 0) > 0){
                return pins.count
            }
            else{
                switch isInitialDownload{
                case true:
                    return 0
                case false:
                    return 1
                }
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
            let headerView : ProfileHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath as IndexPath) as! ProfileHeaderReusableView
            headerView.headerDelegate = self
            //Configure Cell
            headerView.configure(dbUser: user)
            
            reusableView = headerView
        }
        return reusableView!
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        switch(segmentedControlCurrentIndex) {
        case 0:
            if((boards?.count ?? 0) > 0){
                return CGSize(width: collectionView.frame.width, height: 246)
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 200)
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
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int{
        switch(segmentedControlCurrentIndex){
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
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,heightForHeaderInSection section: Int) -> CGFloat{
        return 233
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        switch(segmentedControlCurrentIndex){
        case 0:
            return UIEdgeInsets(top: 5, left: 15, bottom: 40, right: 15)
        case 1:
            return UIEdgeInsets(top: 5, left: 15, bottom: 25, right: 15)
        default:
            return UIEdgeInsets(top: 5, left: 15, bottom: 25, right: 15)
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        switch(segmentedControlCurrentIndex){
        case 0:
            return 40
        case 1:
            return 15
        default:
            return 15
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch(segmentedControlCurrentIndex){
        case 0:
            //Setup Boards CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: boardCellIdentifier, for: indexPath) as! PIBoardCell
            cell.boardCellDelegate = self
            if((boards?.count ?? 0) > 0){
                let board = boards[indexPath.item]
                cell.configure(dbBoard: board)
            }
            else{
                switch isInitialDownload{
                case true:
                    //Do not configure cell
                    break
                case false:
                    cell.configureEmpty()
                    break
                }
            }
            return cell
        case 1:
            //Setup Pins CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pinCellIdentifier, for: indexPath) as! PIPinCell
            if((pins?.count ?? 0) > 0){
                //Configure Pin Cells
                let pin = pins[indexPath.item]
                cell.configure(dbPin: pin)
            }
            else{
                switch isInitialDownload{
                case true:
                    //Do not configure
                    break
                case false:
                    cell.configureEmpty(showLabel: true)
                }
            }
            return cell
        default:
            //Setup Boards CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: boardCellIdentifier, for: indexPath) as! PIBoardCell
            cell.boardCellDelegate = self
            cell.configureEmpty()
            return cell
        }
    }
    
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch(segmentedControlCurrentIndex){
        case 0:
            if((boards?.count ?? 0) > 0){
                //Push Board Detail Controller
                let boardDetailVC = BoardDetailController()
                let board = boards[indexPath.item]
                boardDetailVC.board = board
                boardDetailVC.boardCreator = user
                boardDetailVC.boardCreatorId = user.objectId
                boardDetailVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(boardDetailVC, animated: true)
            }
            
            break
        case 1:
            //Setup CollectionView Flow Layout
            let flowLayout = createDefaultCollectionViewFlowLayout()
            
            //Setup Detail Pin Controller
            let pinDetailVC = PIPinDetailController(collectionViewLayout: flowLayout, currentIndexPath:indexPath, pins:Array(pins))
            collectionView.setToIndexPath(indexPath)
            navigationController!.pushViewController(pinDetailVC, animated: true)
            break
        default:
            break
        }
    }
    
    //Transition Delegates
    func viewWillAppearWithPageIndex(_ pageIndex: NSInteger) {
        var position: UICollectionViewScrollPosition =
            UICollectionViewScrollPosition.centeredHorizontally.intersection(.centeredVertically)
        let pin = pins[pageIndex]
        let cellWidth = CGFloat((w-45)/2)
        let imageHeight = cellWidth*CGFloat((pin.imageHeight/pin.imageWidth))
        if imageHeight > 400 {
            position = .top
        }
        let currentIndexPath = IndexPath(row: pageIndex, section: 0)
        let collectionView = self.collectionView
        collectionView.setToIndexPath(currentIndexPath)
        if pageIndex < 2 {
            collectionView.setContentOffset(CGPoint.zero, animated: false)
        }
        else {
            collectionView.scrollToItem(at: currentIndexPath, at: position, animated: false)
        }
    }
    
    func transitionCollectionView() -> UICollectionView!{
        return collectionView
    }
    
    //BarButtonItem Delegates
    func backButtonPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func sendButtonPressed(){
        let popupVC = PISendPopupController()
        popupVC.sendPopupDelegate = self
        popupVC.contentSizeInPopup = CGSize(width: w, height: 60)
        let popupController = STPopupController.init(rootViewController: popupVC)
        popupController.style = .bottomSheet
        STPopupNavigationBar.appearance().barTintColor = UIColor.white
        STPopupNavigationBar.appearance().tintColor = UIColor.lightGray
        STPopupNavigationBar.appearance().barStyle = .default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.darkGray]
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
        popupController.present(in: self)
    }
    
    func dismissPopupVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func followButtonPressed(){
        //Follow User
        let userManager = UserManager()
        if(user != nil && user.objectId != currentDBUser?.objectId){
            if isFollowing{
                isFollowing = false
                userManager.unfollowUser(uid: uid)
                let followers = user.followerCount
                user.followerCount = followers-1
                self.updateFollowButton(enabled: true, isFollowing: isFollowing)
            }
            else{
                isFollowing = true
                userManager.followUser(uid: uid)
                let followers = user.followerCount
                user.followerCount = followers+1
                self.updateFollowButton(enabled: true, isFollowing: isFollowing)
            }
            
            self.collectionView.reloadData()
        }
        else{
            //Show Error
        }
    }
    
    //Header Delegates
    func didPressProfilePicture() {
        //Do Nothing
    }
    
    func didPressFollowersSection() {
        //Show Followers Controller
        let followersVC = FollowersController()
        followersVC.user = user
        followersVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(followersVC, animated: true)
    }
    
    func didPressFollowingSection() {
        //Show Following Controller
        let followingVC = FollowingController()
        followingVC.user = user
        followingVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(followingVC, animated: true)
    }
    
    func segmentedControlValueChanged(index: Int) {
        //Segmented Control Delegate
        self.segmentedControlCurrentIndex = index
        //Reload CollectionView
        self.collectionView.reloadData()
        //Scroll CollectionView Up to hide header
        let offset = Double(266-navigationHeaderAndStatusbarHeight-20)
        let collectionViewContentOffset = CGPoint(x: 0, y: Double(offset));
        collectionView.setContentOffset(collectionViewContentOffset, animated: true)
    }
    
    //Board Cell Delegate
    func didPressFollow(sender: UIButton){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
        
        //TODO: Implement Board Follow
        /*
        let touchPoint = sender.convert(CGPoint.zero, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: touchPoint)
        if(indexPath != nil){
            //let board = boards[(indexPath?.item)!]
        }*/
    }
    
    //Send Popup Delegates
    func didPressChooseFromContacts() {
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
}
