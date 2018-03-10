//
//  HomeController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import Toast_Swift

class HomeController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, UISearchResultsUpdating, UISearchBarDelegate, PISearchControllerDelegate, PITransitionProtocol, PIWaterFallViewControllerProtocol{
    
    private var pins = Array<DBPin>()
    private var isInitialDownload = Bool()
    private var isAtEndOfData = Bool()
    private var isLoadingData = Bool()
    private let cellIdentifier = "cell"
    private var refreshControl = UIRefreshControl()
    private var searchController: PISearchController!
    private let navigationDelegate = PINavigationControllerDelegate()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 25, right: 15)
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width:w, height:h), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.navigationController!.delegate = navigationDelegate
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup Data
        isInitialDownload = true
        isAtEndOfData = false
        isLoadingData = false
        self.downloadData(endValue: currentTimestamp(), refresh: false)
        
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
    }

    //MARK: Download Data
    func downloadData(endValue: Double?, refresh: Bool){
        //Download Pins
        let pinManager = PinManager()
        if(refresh == true || (refresh == false && isAtEndOfData == false && isLoadingData == false)){
            isLoadingData = true
            pinManager.downloadDiscoverPins(endValue: endValue) { (dbPins: [DBPin]) in
                //Update Pins Array
                if (refresh == true){
                    self.pins = dbPins
                }
                else{
                    self.pins.append(contentsOf: dbPins)
                }
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
                
                //Check if At the End of Data
                if(dbPins.count == 0){
                    self.isAtEndOfData = true
                }
                else{
                    self.isAtEndOfData = false
                }
                
                self.isLoadingData = false
                self.isInitialDownload = false
            }
        }
        else{
            isLoadingData = false
        }
    }
    
    func refreshData(){
        self.downloadData(endValue: currentTimestamp(), refresh: true)
    }
    
    //Setup View
    func setupView(){
        //Setup CollectionView
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        //Register Cell for CollectionView
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        //Setup RefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.layer.zPosition = -1
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        self.view.addSubview(collectionView)
    }
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int{
        if(pins.count > 0){
            return 2
        }
        else{
            return 1
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        if(pins.count > 0){
            //Setup Pins CollectionView
            let pin = pins[indexPath.item]
            let cellWidth = CGFloat((w-45)/2)
            return CGSize(width: cellWidth, height: cellWidth*CGFloat((pin.imageHeight/pin.imageWidth)))
        }
        else{
            return CGSize(width: collectionView.frame.width, height: 200)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Pins CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPinCell
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
        cell.setNeedsLayout()
        return cell;
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Setup CollectionView Flow Layout
        let flowLayout = createDefaultCollectionViewFlowLayout()
        
        //Setup Detail Pin Controller
        let pinDetailVC = PIPinDetailController(collectionViewLayout: flowLayout, currentIndexPath:indexPath, pins:pins)
        collectionView.setToIndexPath(indexPath)
        navigationController!.pushViewController(pinDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item + 1 == pins.count && pins.count < paginationUpperLimit {
            if(isInitialDownload == false && isLoadingData == false && isAtEndOfData == false){
                let pin = pins[indexPath.item]
                downloadData(endValue: pin.createdAt-1, refresh: false)
            }
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
        
        self.collectionView.setToIndexPath(currentIndexPath)
        if pageIndex < 2 {
            self.collectionView.setContentOffset(CGPoint.zero, animated: false)
        }
        else {
            self.collectionView.scrollToItem(at: currentIndexPath, at: position, animated: false)
        }
    }

    func transitionCollectionView() -> UICollectionView!{
        return self.collectionView
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

