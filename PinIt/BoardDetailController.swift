//
//  BoardDetailController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import STPopup
import RealmSwift

class BoardDetailController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, BoardDetailHeaderDelegate, SendPopupDelegate, AddCollaboratorsPopupDelegate, PITransitionProtocol, PIWaterFallViewControllerProtocol{
    
    var board: DBBoard!
    var boardCreatorId: String!
    var boardCreator: DBUser!
    private var pins: Array<DBPin>!
    private var cellIdentifier = "cell"
    private let headerIdentifier = "header"
    private var sendBtn: UIButton!
    private var sendButton: UIBarButtonItem!
    private var organizeBtn: UIButton!
    private var organizeButton: UIBarButtonItem!
    private let navigationDelegate = PINavigationControllerDelegate()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = CHTCollectionViewWaterfallLayout()
        layout.headerHeight = 175
        layout.minimumColumnSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 25, right: 15)
        
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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.navigationController!.delegate = navigationDelegate
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download Data
        self.downloadData()
        
        //Setup View
        self.setupView()
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        //Setup Navigation Items
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        //Setup Send Button
        sendBtn = UIButton.init(type: .custom)
        sendBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 35)
        sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendBtn.setTitleColor(UIColor.darkGray, for: .normal)
        sendBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendBtn.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
        sendBtn.backgroundColor = PIColor.faintGray
        sendBtn.layer.cornerRadius = 2
        sendBtn.clipsToBounds = true
        sendButton = UIBarButtonItem(customView: sendBtn)
        //Setup Save Button
        organizeBtn = UIButton.init(type: .custom)
        organizeBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 35)
        organizeBtn.setTitle(NSLocalizedString("Organize", comment: ""), for: .normal)
        organizeBtn.setTitleColor(UIColor.darkGray, for: .normal)
        organizeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        organizeBtn.addTarget(self, action: #selector(self.organizeButtonPressed), for: .touchUpInside)
        organizeBtn.backgroundColor = PIColor.faintGray
        organizeBtn.layer.cornerRadius = 2
        organizeBtn.clipsToBounds = true
        organizeButton = UIBarButtonItem(customView: organizeBtn)
        if(board.createdBy == currentDBUser?.objectId){
            self.navigationItem.rightBarButtonItems = [organizeButton, sendButton]
        }
        else{
            self.navigationItem.rightBarButtonItem = sendButton
        }
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //MARK: Setup View
    func setupView(){
        //Setup CollectionView
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(BoardDetailHeaderReusableView.self, forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        self.view.addSubview(collectionView)
        
        //Setup RefreshControl
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    //MARK: Download Data
    func downloadData(){
        //Download Pin Data
        let pinManager = PinManager()
        if(board?.createdBy == currentDBUser?.objectId){
            //Set Board Creator
            boardCreator = currentDBUser
            //Download the board's pins
            pinManager.loadPins(uid: board?.createdBy, boardId:board?.objectId, completionHandler: { (pinResults: Results<DBPin>?) in
                if(pinResults != nil){
                    self.pins = Array(pinResults!)
                }
                else{
                    self.pins = nil
                }
                
                self.collectionView.reloadData()
            } )
        }
        else{
            //Download Board Creator
            if(boardCreator == nil){
                let userManager = UserManager()
                userManager.downloadUser(uid: boardCreatorId, completionHandler: { (user: DBUser?, isFollowing: Bool?, rawData: NSDictionary?) in
                    if(user != nil){
                        self.boardCreator = user
                        
                        //Reload CollectionView header
                        self.collectionView.reloadData()
                    }
                })
            }
        
            //Download Pins
            pinManager.downloadPins(uid: board?.createdBy, boardId:board?.objectId, completionHandler: { (pinResults: [DBPin]?) in
                if(pinResults != nil){
                    self.pins = pinResults!
                }
                else{
                    self.pins = nil
                }
                
                self.collectionView.reloadData()
            })
        }
        
    }
    
    func refreshData(){
        self.downloadData()
        refreshControl.endRefreshing()
    }
    
    //CollectionView Datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (pins?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil
        // Create header
        if (kind == CHTCollectionElementKindSectionHeader) {
            // Create Header
            let headerView : BoardDetailHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: CHTCollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath as IndexPath) as! BoardDetailHeaderReusableView
            headerView.headerDelegate = self
            //Configure Cell
            headerView.configure(dbBoard:board, dbPins: pins, dbUser: boardCreator)
            reusableView = headerView
        }
        return reusableView!
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        if(pins.count > 0){
            //Setup Pins CollectionView
            let pin = pins[indexPath.item]
            let cellWidth = CGFloat((w-45)/2)
            return CGSize(width: cellWidth, height: cellWidth*CGFloat((pin.imageHeight/pin.imageWidth)))
        }
        else{
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //Setup Pins CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPinCell
        if(pins.count > 0){
            //Configure Pin Cells
            let pin = pins?[indexPath.item]
            cell.configure(dbPin: pin)
        }
        
        return cell
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        //Setup CollectionView Flow Layout
        let flowLayout = createDefaultCollectionViewFlowLayout()
        
        //Setup Detail Pin Controller
        let pinDetailVC = PIPinDetailController(collectionViewLayout: flowLayout, currentIndexPath:indexPath, pins:pins)
        collectionView.setToIndexPath(indexPath)
        navigationController!.pushViewController(pinDetailVC, animated: true)
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
        popupVC.title = NSLocalizedString("Send Board", comment: "")
        let popupController = STPopupController.init(rootViewController: popupVC)
        popupController.style = .bottomSheet
        STPopupNavigationBar.appearance().barTintColor = UIColor.white
        STPopupNavigationBar.appearance().tintColor = UIColor.lightGray
        STPopupNavigationBar.appearance().barStyle = .default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.darkGray]
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
        popupController.present(in: self)
    }
    
    func organizeButtonPressed(){
        let organizeBoardVC = OrganizeBoardController()
        organizeBoardVC.pins = pins
        let navVC = NavigationController.init(rootViewController: organizeBoardVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    //Header Delegates
    func didPressAddCollaborators(){
        let popupVC = AddCollaboratorsPopupController()
        popupVC.contentSizeInPopup = CGSize(width: w, height: 60)
        popupVC.addCollaboratorsPopupDelegate = self
        let popupController = STPopupController.init(rootViewController: popupVC)
        popupController.style = .bottomSheet
        STPopupNavigationBar.appearance().barTintColor = UIColor.white
        STPopupNavigationBar.appearance().tintColor = UIColor.lightGray
        STPopupNavigationBar.appearance().barStyle = .default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.darkGray]
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
        popupController.present(in: self)
    }
    
    //Popup Methods
    func dismissPopupVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Popup Delegates
    func didPressChooseFromContacts() {
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressAddCollaboratorsFromContacts(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressProfilePicture(){
        //Show Profile for User
        let userDetailVC = UserDetailController()
        userDetailVC.uid = boardCreatorId
        self.navigationController?.pushViewController(userDetailVC, animated: true)
    }
}
