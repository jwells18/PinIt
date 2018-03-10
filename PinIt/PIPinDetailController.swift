//
//  HomeDetailController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/19/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import UIKit
import STPopup

class PIPinDetailController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,PITransitionProtocol, PIPinDetailControllerProtocol, PIPinDetailCellDelegate, EditPinMoreOptionsPopupDelegate, SendPopupDelegate{
    
    private let cellIdentifier = "cell"
    private var currentIndexPath: IndexPath!
    private var backButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    private var moreButton: UIBarButtonItem!
    private var sendBtn: UIButton!
    private var sendButton: UIBarButtonItem!
    private var saveBtn: UIButton!
    private var saveButton: UIBarButtonItem!
    var pins: Array<DBPin>!
    var pullOffset = CGPoint.zero
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:navigationHeaderAndStatusbarHeight, width:w, height:h-navigationHeaderAndStatusbarHeight), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    
    init(collectionViewLayout layout: UICollectionViewLayout!, currentIndexPath indexPath: IndexPath, pins: Array<DBPin>){
        super.init(nibName: nil, bundle: nil)
        //Set CurrentIndexPath
        self.currentIndexPath = indexPath
        self.pins = pins
        //Setup CollectionView
        collectionView.collectionViewLayout = layout
        collectionView.register(PIPinDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.setToIndexPath(indexPath)
        collectionView.performBatchUpdates({self.collectionView.reloadData()}, completion: { finished in
            if finished {
                self.collectionView.scrollToItem(at: indexPath,at:.centeredHorizontally, animated: false)
            }});
        self.view.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white

        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationController?.navigationBar.backgroundColor = UIColor.white

        //Setup Navigation Items
        backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        //Setup More Button
        let editBtn = UIButton.init(type: .custom)
        editBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        editBtn.setImage(UIImage(named:"edit"), for: .normal)
        editBtn.addTarget(self, action: #selector(self.editButtonPressed), for: .touchUpInside)
        editButton = UIBarButtonItem(customView: editBtn)
        //Setup More Button
        let moreBtn = UIButton.init(type: .custom)
        moreBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        moreBtn.setImage(UIImage(named:"more"), for: .normal)
        moreBtn.addTarget(self, action: #selector(self.moreButtonPressed), for: .touchUpInside)
        moreButton = UIBarButtonItem(customView: moreBtn)
        if(currentIndexPath.item <= pins.count-1){
            let pin = pins[currentIndexPath.item]
            if(pin.createdBy == currentDBUser?.objectId){
                self.navigationItem.leftBarButtonItems = [backButton, editButton, moreButton]
            }
            else{
                self.navigationItem.leftBarButtonItems = [backButton, moreButton]
            }
        }
        else{
            self.navigationItem.leftBarButtonItems = [backButton, moreButton]
        }

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
        //Setup Save Button
        saveBtn = UIButton.init(type: .custom)
        saveBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveBtn.setTitleColor(UIColor.white, for: .normal)
        saveBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        saveBtn.addTarget(self, action: #selector(self.saveButtonPressed), for: .touchUpInside)
        saveBtn.backgroundColor = PIColor.primary
        saveBtn.layer.cornerRadius = 2
        saveBtn.clipsToBounds = true
        saveButton = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItems = [saveButton, sendButton]
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //MARK: Setup View
    func setupView(){
        //Increase bottom inset so view shows above Tabbar
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (pins?.count ?? 0)
    }
    
    //CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PIPinDetailCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPinDetailCell
        cell.pinDetailDelegate = self
        if(pins.count > 0){
            //Configure Pin Cells
            cell.pin = pins[indexPath.item]
            cell.tappedAction = {}
            cell.pullAction = { offset in
                self.pullOffset = offset
                self.navigationController!.popViewController(animated: true)
            }
        }
        cell.setNeedsLayout()
        cell.setNeedsDisplay()
        
        return cell
    }
    
    //Transition Delegates
    func transitionCollectionView() -> UICollectionView!{
        return collectionView
    }
    
    func pageViewCellScrollViewContentOffset() -> CGPoint{
        return self.pullOffset
    }

    //BarButtonItem Delegates
    func backButtonPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func editButtonPressed(){
        //Show Edit Button
        let editPinVC = PIEditPinController()
        let pin = pins[(currentIndexPath?.item)!]
        editPinVC.pin = pin
        let navVC = NavigationController.init(rootViewController: editPinVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func moreButtonPressed(){
        let popupVC = EditPinMoreOptionsPopupController()
        popupVC.contentSizeInPopup = CGSize(width: w, height: 147)
        popupVC.editPinMoreOptionsPopupDelegate = self
        let popupController = STPopupController.init(rootViewController: popupVC)
        popupController.style = .bottomSheet
        STPopupNavigationBar.appearance().barTintColor = UIColor.white
        STPopupNavigationBar.appearance().tintColor = UIColor.lightGray
        STPopupNavigationBar.appearance().barStyle = .default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.darkGray]
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
        popupController.present(in: self)
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
    
    func saveButtonPressed(){
        //Show Create Pin Controller
        let createPinVC = CreatePinController()
        let navVC = NavigationController.init(rootViewController: createPinVC)
        //Get Current Pin
        let currentIndexPaths = collectionView.indexPathsForVisibleItems
        let currentIndexPath = currentIndexPaths.first
        let pin = pins[(currentIndexPath?.item)!]
        createPinVC.dbPin = pin
        self.present(navVC, animated: true, completion: nil)
    }
    
    func dismissPopupVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Detail Pin Delegate
    func didPressAddPhotoOrNote() {
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressAddComment() {
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressUserDetail() {
        //Push User Detail Controller
        let userDetailVC = UserDetailController()
        let pin = pins[(currentIndexPath?.item)!]
        userDetailVC.uid = pin.createdBy
        self.navigationController?.pushViewController(userDetailVC, animated: true)
    }

    //More Options Popup Delegate
    func didPressDownloadImage() {
        //Save Image to Phone
        let pin = pins[currentIndexPath.item]
        let imageUrl = URL(string: pin.image)
        _ = downloadImage(url: imageUrl!) { (image: UIImage?, response: URLResponse?, error: Error?) in
            if((image) != nil){
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            else{
                //Show Error Message
            }
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            //Show Save Successfull
            let toastDict:[String: Any] = ["message": NSLocalizedString("Downloaded!", comment: "")]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
        }
        else{
            //Show Error Message
            let toastDict:[String: Any] = ["message": NSLocalizedString("Error downloading image", comment: "")]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
        }
    }
    
    func didPressCopy(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    func didPressReport(){
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    //Send Popup Delegates
    func didPressChooseFromContacts() {
        //Show Feature Unavailable
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
    
    
}
