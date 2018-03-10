//
//  DiscoverController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import PinterestSegment

class DiscoverController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, PISearchControllerDelegate, UIScrollViewDelegate, DiscoverSectionCellDelegate{
    
    private var segmentedControl: PinterestSegment!
    private var searchController: PISearchController!
    private let cellIdentifier = "cell"
    private var segmentedControlCurrentIndex = 0
    public var discoverSectionDict = Dictionary<String, [DBPin]>()
    public var peopleToFollowSectionDict = Dictionary<String, [DBUser]>()
    public var peopleToFollowSectionFollowingDict = Dictionary<String, [Bool]>()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:44, width:w, height:h-44-navigationHeaderAndStatusbarHeight), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.white
        
        return collectionView
    }()
    private var pins: [DBPin]!
    private var users: [DBUser]!
    private var isInitialDownloadDict = Dictionary<String, Bool>()
    private var isAtEndOfDataDict = Dictionary<String, Bool>()
    private var isLoadingDataDict = Dictionary<String, Bool>()
    private let navigationDelegate = PINavigationControllerDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Set Initial Values
        for sectionTitle in discoverSectionTitles{
            isInitialDownloadDict[sectionTitle] = true
            isAtEndOfDataDict[sectionTitle] = false
            isLoadingDataDict[sectionTitle] = false
        }
        
        //Download Pins for Section
        self.downloadPinData(endValue: currentTimestamp())
        self.downloadPeopleToFollow()
        
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
        let style = PinterestSegmentStyle()
        segmentedControl = PinterestSegment(frame: CGRect(x:0, y:5, width:w,height:34), segmentStyle: style, titles: discoverSectionTitles)
        segmentedControl.valueChange = { index in
            
            //Refresh CollectionViw
            let scrollIndexPath = IndexPath(row: index, section: 0)
            if(abs(self.segmentedControlCurrentIndex-index) >= 2){
                //Do not animate scroll
                self.collectionView.scrollToItem(at: scrollIndexPath, at: .centeredHorizontally, animated: false)
            }
            else{
                //Animate Scroll
                self.collectionView.scrollToItem(at: scrollIndexPath, at: .centeredHorizontally, animated: true)
            }
            
            self.segmentedControlCurrentIndex = index
        }
        self.view.addSubview(segmentedControl)
        
        //Setup BottomNavBar Container View
        let bottomNavView = UIView(frame: CGRect(x:0,y:0, width:w,height:44))
        bottomNavView.backgroundColor = UIColor.white
        //Add Gray hairline
        let bottomNavViewLine = CALayer()
        bottomNavViewLine.frame = CGRect(x: 0, y: 44, width: w, height: 0.5)
        bottomNavViewLine.backgroundColor = UIColor.lightGray.cgColor
        bottomNavView.layer.addSublayer(bottomNavViewLine)
        
        //Add BottomNavBar to View
        bottomNavView.addSubview(segmentedControl)
        self.view.addSubview(bottomNavView)
    }
    
    //MARK: Download Data
    func downloadPinData(endValue: Double?){
        //Download Pins
        let discoverSectionTitle = discoverSectionTitles[segmentedControlCurrentIndex]
        let pinManager = PinManager()
        if(isAtEndOfDataDict[discoverSectionTitle] == false && isLoadingDataDict[discoverSectionTitle] == false){
            isLoadingDataDict[discoverSectionTitle] = true
            pinManager.downloadDiscoverPins(endValue: endValue) { (dbPins: [DBPin]) in
                //Update Pins Array
                var currentPins = self.discoverSectionDict[discoverSectionTitle]
                if(currentPins != nil){
                    currentPins?.append(contentsOf: dbPins)
                }
                else{
                    currentPins = dbPins
                }
                self.discoverSectionDict[discoverSectionTitle] = currentPins
                
                self.collectionView.reloadData()
                
                //Check if At the End of Data
                if(dbPins.count == 0){
                    self.isAtEndOfDataDict[discoverSectionTitle] = true
                }
                else{
                    self.isAtEndOfDataDict[discoverSectionTitle] = false
                }
                
                self.isLoadingDataDict[discoverSectionTitle] = false
                self.isInitialDownloadDict[discoverSectionTitle] = false
            }
        }
        else{
            isLoadingDataDict[discoverSectionTitle] = false
        }
    }
    
    func downloadPeopleToFollow(){
        let discoverSectionTitle = discoverSectionTitles[segmentedControlCurrentIndex]
        let userManager = UserManager()
        userManager.downloadPeopleToFollow { (users: [DBUser]?, isFollowingArray: [Bool]?) in
            self.peopleToFollowSectionDict[discoverSectionTitle] = users
            self.peopleToFollowSectionFollowingDict[discoverSectionTitle] = isFollowingArray
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.collectionView.performBatchUpdates({
                    let indexSet = IndexSet(integer: 0)
                    self.collectionView.reloadSections(indexSet)
                }, completion: nil)
            })
        }
    }
    
    //MARK: Setup View
    func setupView(){
        //Setup CollectionView
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        //Setup Collection
        collectionView.register(DiscoverSectionCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.view.addSubview(collectionView)
    }
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discoverSectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Discover Section Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DiscoverSectionCell
        cell.discoverSectionCellDelegate = self
        let discoverSectionTitle = discoverSectionTitles[indexPath.row]
        pins = self.discoverSectionDict[discoverSectionTitle]
        users = self.peopleToFollowSectionDict[discoverSectionTitle]
        let peopleToFollowFollowingArray = self.peopleToFollowSectionFollowingDict[discoverSectionTitle]
        cell.configure(dbPins: pins, dbUsers: users, isFollowing: peopleToFollowFollowingArray, section: discoverSectionTitle)
        
        return cell
    }
    
    //CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let discoverSectionTitle = discoverSectionTitles[indexPath.item]
        if(self.discoverSectionDict[discoverSectionTitle] == nil && isInitialDownloadDict[discoverSectionTitle] == true){
            downloadPinData(endValue: currentTimestamp())
            downloadPeopleToFollow()
        }
    }
    
    //Discover Section Cell Delegate
    func didPressDiscoverPinCell(indexPath: IndexPath){

        //Setup CollectionView Flow Layout
        let flowLayout = createDefaultCollectionViewFlowLayout()
        
        //Setup Detail Pin Controller
        let discoverSectionTitle = discoverSectionTitles[segmentedControlCurrentIndex]
        pins = self.discoverSectionDict[discoverSectionTitle]
        let sectionIndexPath = IndexPath(item: segmentedControlCurrentIndex, section: 0)
        let sectionCell = self.collectionView.cellForItem(at: sectionIndexPath) as! DiscoverSectionCell
        sectionCell.collectionView.setToIndexPath(indexPath)
        //Setup Detail Pin Controller
        let currentIndex = IndexPath(item: indexPath.item, section: 0)
        let pinDetailVC = PIPinDetailController(collectionViewLayout: flowLayout, currentIndexPath:currentIndex, pins:pins)
        navigationController!.pushViewController(pinDetailVC, animated: true)
    }
    
    func willDisplayDiscoverPinCell(cell: UICollectionViewCell, indexPath: IndexPath){
        //Download Data for section (if necessary)
        let discoverSectionTitle = discoverSectionTitles[segmentedControlCurrentIndex]
        pins = self.discoverSectionDict[discoverSectionTitle]
        let pinCount = (pins?.count ?? 0)
        if indexPath.item + 1 == pinCount && pinCount < paginationUpperLimit {
            if(isInitialDownloadDict[discoverSectionTitle] == false && isLoadingDataDict[discoverSectionTitle] == false && isAtEndOfDataDict[discoverSectionTitle] == false){
                let pin = pins[indexPath.item]
                downloadPinData(endValue: pin.createdAt-1)
            }
        }
    }
    
    func didPressPeopleToFollowCell(indexPath: IndexPath){
        //Push User Detail Controller
        let userDetailVC = UserDetailController()
        
        let discoverSectionTitle = discoverSectionTitles[segmentedControlCurrentIndex]
        
        self.users = self.peopleToFollowSectionDict[discoverSectionTitle]
       
        let user = self.users[indexPath.row]
        userDetailVC.uid = user.objectId
        userDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(userDetailVC, animated: true)
    }
    
    //ScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView == self.collectionView){
            //Change SegmentedControl index to match ScrollView index
            let pageWidth = scrollView.frame.size.width;
            let page = Int(scrollView.contentOffset.x / pageWidth);
            self.segmentedControl.setSelectIndex(index: page)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
