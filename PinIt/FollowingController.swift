//
//  FollowingController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class FollowingController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PeopleFollowCellDelegate, BoardFollowCellDelegate, TopicFollowCellDelegate{
    
    private let topicFollowCellIdentifier = "topicFollowCell"
    private let peopleFollowCellIdentifier = "peopleFollowCell"
    private let boardFollowCellIdentifier = "boardFollowCell"
    private let headerIdentifier = "header"
    private var segmentedControlCurrentIndex = 0
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: w, height:260)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 25, right: 15)
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width:w, height:h-navigationHeaderAndStatusbarHeight), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        
        return collectionView
    }()
    var user: DBUser!
    private var users: [DBUser]!
    private var boards: [DBBoard]!
    private var isFollowingArray: [Bool]!
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download User Data
        self.downloadUser()
        
        //Setup View
        self.setupView()
    }
    
    func setupNavigationBar(){
        //Setup Navigation Items
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //Download User
    func downloadUser(){
        let userManager = UserManager()
        userManager.downloadUser(uid: user.objectId) { (user: DBUser?, isFollowingUser: Bool?, rawData: NSDictionary?) in
            self.user = user
            if(user != nil){
                self.downloadFollowing(rawData: rawData)
            }
        }
    }
    
    //Download Data
    func downloadFollowing(rawData: NSDictionary?){
        if(rawData != nil){
            //Download Follower's User Data
            let followingDict = rawData?["followingIds"] as? NSDictionary
            let followingIds = followingDict?.allKeys
            
            let userManager = UserManager()
            userManager.downloadUsers(uids: followingIds as! [String]?, completionHandler: { (users: [DBUser]?, isFollowing: [Bool]?) in
                self.users = users
                self.isFollowingArray = isFollowing
                self.collectionView.reloadData()
            })
        }
    }
    
    //Setup View
    func setupView(){
        //Setup CollectionView
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        //Register CollectionView Cells
        collectionView.register(PITopicFollowCell.self, forCellWithReuseIdentifier: topicFollowCellIdentifier)
        collectionView.register(PIPeopleFollowCell.self, forCellWithReuseIdentifier: peopleFollowCellIdentifier)
        collectionView.register(PIBoardFollowCell.self, forCellWithReuseIdentifier: boardFollowCellIdentifier)
        collectionView.register(FollowingHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //Setup RefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch(segmentedControlCurrentIndex) {
        case 0:
            if((users?.count ?? 0) > 0 ){
                return (users?.count)!
            }
            else{
                return 1
            }
        case 1:
            if((boards?.count ?? 0) > 0 ){
                return (boards?.count)!
            }
            else{
                return 1
            }
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellWidth: CGFloat = (w-45)/2
        switch(segmentedControlCurrentIndex) {
        case 0:
            if((users?.count ?? 0) > 0 ){
                return CGSize(width: cellWidth, height:cellWidth+5+26+10+30)
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 200)
            }
        case 1:
            if((boards?.count ?? 0) > 0 ){
                return CGSize(width: cellWidth, height:cellWidth+15+22+18+10+30)
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 200)
            }
            
        case 2:
            return CGSize(width: collectionView.frame.width, height: 200)
            //return CGSize(width: cellWidth, height:cellWidth+10+30)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        // Create header
        if (kind == UICollectionElementKindSectionHeader) {
            // Create Header
            let headerView : FollowingHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath as IndexPath) as! FollowingHeaderReusableView
            headerView.configure(dbUser: user)
            headerView.segmentedControl.didSelectItemWith = { (index, title) -> () in
                self.segmentedControlCurrentIndex = index
                //Reload CollectionView
                self.collectionView.reloadData()
            }
            
            reusableView = headerView
        }
        return reusableView!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch(segmentedControlCurrentIndex){
        case 0:
            //Setup People CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: peopleFollowCellIdentifier, for: indexPath) as! PIPeopleFollowCell
            cell.peopleFollowCellDelegate = self
            if((users?.count ?? 0) > 0 ){
                let user = users[indexPath.row]
                let isFollowing = isFollowingArray[indexPath.row]
                cell.configure(dbUser: user, isFollowing: isFollowing)
            }
            else{
                cell.configureEmpty(showLabel: true, text:NSLocalizedString("No Following",comment:""))
            }
            return cell
        case 1:
            //Setup Boards CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: boardFollowCellIdentifier, for: indexPath) as! PIBoardFollowCell
            cell.boardFollowCellDelegate = self
            if((boards?.count ?? 0) > 0 ){
                cell.configure()
            }
            else{
                cell.configureEmpty(showLabel: true, text:NSLocalizedString("No Boards",comment:""))
            }
            return cell
        case 2:
            //Setup Topics CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topicFollowCellIdentifier, for: indexPath) as! PITopicFollowCell
            cell.topicFollowCellDelegate = self
            cell.configureEmpty(showLabel: true, text:NSLocalizedString("No Topics",comment:""))
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topicFollowCellIdentifier, for: indexPath) as! PITopicFollowCell
            return cell
        }
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch(segmentedControlCurrentIndex) {
        case 0:
            if((users?.count ?? 0) > 0 ){
                //Show Feature Unavailable
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                /*
                //Push User Detail Controller
                let userDetailVC = UserDetailController()
                let user = users[indexPath.row]
                userDetailVC.uid = user.objectId
                userDetailVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(userDetailVC, animated: true)*/
            }
            break
        case 1:
            //Show Feature Unavailable
            self.present(featureUnavailableAlert(), animated: true, completion: nil)
            break
        case 2:
            //Show Feature Unavailable
            self.present(featureUnavailableAlert(), animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    //MARK: BarButtonItem Delegates
    func backButtonPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Cell Delegates
    func didPressPeopleFollow(sender: UIButton){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressBoardFollow(sender: UIButton){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressTopicFollow(sender: UIButton){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    
    //Other Functions
    func refreshData(){
        refreshControl.endRefreshing()
    }

}
