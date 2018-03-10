//
//  NotificationsController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import TTSegmentedControl
import RealmSwift

class NotificationsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIScrollViewDelegate, PISearchControllerDelegate, NotificationDelegate, InboxDelegate{
    
    private var notifications: Results<DBNotification>!
    private var notificationsCellIdentifier = "notificationsCell"
    private var inboxCellIdentifier = "inboxCell"
    private lazy var searchBar = UISearchBar()
    private var segmentedControlTitles = ["Notifications", "Inbox"];
    private var segmentedControl = TTSegmentedControl()
    private var searchController: PISearchController!
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:44.5, width:w, height:h-44.5-navigationHeaderAndStatusbarHeight), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white

        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Show Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        //Show Status Bar
        return false
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        //Setup SearchController
        searchController = PISearchController(searchResultsController: self, searchBarFrame: CGRect(x:0, y:0, width:w, height:50), searchBarFont: UIFont.boldSystemFont(ofSize: searchBarFontSize), searchBarTextColor: UIColor.darkGray, searchBarTintColor: UIColor.lightGray, searchBarBackgroundColor: PIColor.faintGray)
        searchController.customDelegate = self
        self.navigationItem.titleView = searchController.customSearchBar
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Setup Bottom NavigationBar SegmentedControl
        self.setupBottomNavBar()
    }
    
    func setupBottomNavBar(){
        //Setup SegmentedControl
        segmentedControl.itemTitles = segmentedControlTitles
        segmentedControl.frame = CGRect(x:15,y:5, width:w-30,height:34)
        segmentedControl.containerBackgroundColor = PIColor.faintGray
        segmentedControl.thumbColor = UIColor.white
        segmentedControl.defaultTextColor = UIColor.darkGray
        segmentedControl.selectedTextColor = UIColor.darkGray
        segmentedControl.defaultTextFont = UIFont.boldSystemFont(ofSize: 14)
        segmentedControl.selectedTextFont = UIFont.boldSystemFont(ofSize: 14)
        segmentedControl.allowChangeThumbWidth = false
        segmentedControl.useGradient = false
        segmentedControl.cornerRadius = 0
        segmentedControl.useShadow = false
        segmentedControl.didSelectItemWith = { (index, title) -> () in
            //Set CollectionView index to SegmentedControl index
            self.collectionView.scrollRectToVisible(CGRect(x: w*CGFloat(index), y:0, width: w, height: h), animated: true)
        }
        self.view.addSubview(segmentedControl)

        //Setup BottomNavBar Container View
        let bottomNavView = UIView(frame: CGRect(x:0, y:0, width:w, height:44))
        bottomNavView.backgroundColor = UIColor.white
        
        //Add BottomNavBar to View
        bottomNavView.addSubview(segmentedControl)
        self.view.addSubview(bottomNavView)
    }
    
    //MARK: Setup View
    func setupView(){
        //Setup CollectionView
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        //Setup Collection
        collectionView.register(NotificationsSectionCell.self, forCellWithReuseIdentifier: notificationsCellIdentifier)
        collectionView.register(InboxSectionCell.self, forCellWithReuseIdentifier: inboxCellIdentifier)
        
        self.view.addSubview(collectionView)
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch(indexPath.item){
        case 0:
            //Setup Notifications Section Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationsCellIdentifier, for: indexPath) as! NotificationsSectionCell
            cell.notificationDelegate = self
            return cell
        case 1:
            //Setup Inbox Section Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inboxCellIdentifier, for: indexPath) as! InboxSectionCell
            cell.inboxDelegate = self
            return cell
        default:
            //Setup Notifications Section Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationsCellIdentifier, for: indexPath) as! NotificationsSectionCell
            cell.notificationDelegate = self
            return cell
        }
    }

    //ScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView == self.collectionView){
            //Change SegmentedControl index to match CollectionView index
            let pageWidth = scrollView.frame.size.width;
            let page = Int(scrollView.contentOffset.x / pageWidth);
            segmentedControl.selectItemAt(index: page)
        }
    }
    
    //Notification Delegate
    func didPressNotificationCell(notification: DBNotification?){
        //Push Notification Detail (depends on type)
        //Push Board Detail Controller
        if(notification != nil){
            let boardManager = BoardManager()
            boardManager.downloadBoard(boardId: (notification?.boardId)!, boardCreatorId: (notification?.boardCreatorId)!, completionHandler: { (board: DBBoard?) in
                if(board != nil){
                    let boardDetailVC = BoardDetailController()
                    boardDetailVC.board = board
                    boardDetailVC.boardCreatorId = board?.createdBy
                    boardDetailVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(boardDetailVC, animated: true)
                }
                else{
                    //Show Error Message
                    let toastDict:[String: Any] = ["message": NSLocalizedString("Hmm...this board wasn't found", comment: "")]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
            })
        }
    }
    
    //Inbox Delegate
    func didPressNewMessage(){
        //Show Alert that this feature is not available
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    //SearchController Delegates
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func didStartSearching() {
        
    }
    
    func didEndSearching() {
        
    }
    
    func didTapOnBookmarkButton(){
        let cameraVC = CameraController()
        cameraVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    func didTapOnSearchButton() {
        
    }
    
    
    func didTapOnCancelButton() {
        
    }
    
    
    func didChangeSearchText(searchText: String) {
        
    }
    
}
