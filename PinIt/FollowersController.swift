//
//  FollowersController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/21/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class FollowersController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PeopleFollowCellDelegate{
    
    private let peopleFollowCellIdentifier = "peopleFollowCell"
    private let headerIdentifier = "header"
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: w, height:216)
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
    private var isFollowingArray: [Bool]!
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download User
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
                self.downloadFollowers(rawData: rawData)
            }
        }
    }
    
    //Download Data
    func downloadFollowers(rawData: NSDictionary?){
        if(rawData != nil){
            //Download Follower's User Data
            let followersDict = rawData?["followerIds"] as? NSDictionary
            let followerIds = followersDict?.allKeys
            let userManager = UserManager()
            userManager.downloadUsers(uids: followerIds as! [String]?, completionHandler: { (users: [DBUser]?, isFollowing: [Bool]?) in
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
        collectionView.register(PIPeopleFollowCell.self, forCellWithReuseIdentifier: peopleFollowCellIdentifier)
        collectionView.register(FollowersHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
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
        if((users?.count ?? 0) > 0 ){
            return (users?.count)!
        }
        else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        if((users?.count ?? 0) > 0 ){
            let cellWidth: CGFloat = (w-45)/2
            return CGSize(width: cellWidth, height:cellWidth+5+20+5+30)
        }
        else{
            return CGSize(width: collectionView.frame.width, height: 200)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        
        // Create header
        if (kind == UICollectionElementKindSectionHeader) {
            // Create Header
            let headerView : FollowersHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath as IndexPath) as! FollowersHeaderReusableView
            headerView.configure(dbUser: user)
            reusableView = headerView
        }
        return reusableView!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Topics CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: peopleFollowCellIdentifier, for: indexPath) as! PIPeopleFollowCell
        cell.peopleFollowCellDelegate = self
        if((users?.count ?? 0) > 0 ){
            let user = users[indexPath.row]
            let isFollowing = isFollowingArray[indexPath.row]
            cell.configure(dbUser: user, isFollowing: isFollowing)
        }
        else{
            cell.configureEmpty(showLabel: true, text:NSLocalizedString("No Followers",comment:""))
        }
        return cell
    }
    
    //CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    //Other Functions
    func refreshData(){
        refreshControl.endRefreshing()
    }
    
}
