//
//  ProfileController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import STPopup
import RealmSwift

class ProfileController: UIViewController, UICollectionViewDataSource,  UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, ProfileHeaderDelegate, AddBoardPinPopupDelegate, PITransitionProtocol, PIWaterFallViewControllerProtocol{
    
    private var boards: Results<DBBoard>!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.navigationController!.delegate = navigationDelegate
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download Data
        isInitialDownload = true
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
        let addBtn = UIButton.init(type: .custom)
        addBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addBtn.setImage(UIImage(named:"add"), for: .normal)
        addBtn.addTarget(self, action: #selector(self.addButtonPressed), for: .touchUpInside)
        let addButton = UIBarButtonItem(customView: addBtn)
        
        let settingsBtn = UIButton.init(type: .custom)
        settingsBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        settingsBtn.setImage(UIImage(named:"settings"), for: .normal)
        settingsBtn.addTarget(self, action: #selector(self.settingsButtonPressed), for: .touchUpInside)
        let settingsButton = UIBarButtonItem(customView: settingsBtn)
        
        self.navigationItem.rightBarButtonItems = [settingsButton, addButton];
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //MARK: Download Data
    func downloadData(){
        //Start Activity Indicator
        activityIndicator.startAnimating()
        //Download Board Data
        let boardManager = BoardManager()
        boardManager.loadBoards(uid: (currentDBUser?.objectId)!, completionHandler: { (boardResults: Results<DBBoard>) in
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
        pinManager.loadPins(uid: (currentDBUser?.objectId)!, boardId:nil, completionHandler: { (pinResults: Results<DBPin>?) in
            self.pins = Array(pinResults!)
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
            if(boards.count > 0){
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
            if(pins.count > 0){
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
            headerView.configure(dbUser: currentDBUser)

            reusableView = headerView
        }
        return reusableView!
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        switch(segmentedControlCurrentIndex) {
        case 0:
            if(boards.count > 0){
                return CGSize(width: collectionView.frame.width, height: 246)
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 200)
            }
        case 1:
            if(pins.count > 0){
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
            if(pins.count > 0){
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
            if(boards.count > 0){
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
            if(pins.count > 0){
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
            cell.configureEmpty()
            return cell
        }
    }
    
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch(segmentedControlCurrentIndex){
        case 0:
            if (boards.count > 0){
                //Push Board Detail Controller
                let boardDetailVC = BoardDetailController()
                let board = boards[indexPath.item]
                boardDetailVC.board = board
                boardDetailVC.boardCreator = currentDBUser
                boardDetailVC.boardCreatorId = currentDBUser?.objectId
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
        if imageHeight > 400 {//whatever you like, it's the max value for height of image
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
    
    //MARK: BarButtonItem Delegates
    func addButtonPressed(){
        //Show Add Board Popup Controller
        let popupVC = AddBoardPinPopupController()
        popupVC.contentSizeInPopup = CGSize(width: w, height: 217)
        popupVC.addBoardPinPopupDelegate = self
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
    
    func settingsButtonPressed(){
        //Show Settings Controller
        let settingsVC = SettingsController()
        settingsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    //Header Delegates
    func didPressProfilePicture() {
        //Show Profile Picture Controller
        let profilePictureVC = ProfilePictureController()
        let navVC = NavigationController.init(rootViewController: profilePictureVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func didPressFollowersSection() {
        //Show Followers Controller
        let followersVC = FollowersController()
        followersVC.user = currentDBUser
        followersVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(followersVC, animated: true)
    }
    
    func didPressFollowingSection() {
        //Show Following Controller
        let followingVC = FollowingController()
        followingVC.user = currentDBUser
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
    
    //Popup Delegates 
    func didPressCreateBoard(){
        //Show Create Board Controller
        let createBoardVC = CreateBoardController()
        let navVC = NavigationController.init(rootViewController: createBoardVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func didPressPhoto(){
        //Show Picture Library Controller
        let photoLibraryVC = PIPhotoLibraryController()
        let navVC = NavigationController.init(rootViewController: photoLibraryVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func didPressWebsite(){
        //Show WebView with Terms & Policies
        let webPageVC = PIWebViewController()
        let navVC = NavigationController.init(rootViewController: webPageVC)
        self.present(navVC, animated: true, completion: nil)
    }
}
