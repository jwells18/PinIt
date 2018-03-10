//
//  PIPhotoLibraryController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/20/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Photos
import STPopup

class PIPhotoLibraryController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    private var cellIdentifier = "cell"
    private var allPhotos: PHFetchResult<PHAsset>!
    fileprivate var imageManager = PHCachingImageManager()
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:(w-60)/3, height:(w-60)/3)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width:w, height:h), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        
        return collectionView
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
        
        //Download All Photos
        if (allPhotos == nil){
            //Fetch for new Photos
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [
                        NSSortDescriptor(key: "creationDate", ascending: false)
                    ]
                    self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    DispatchQueue.main.async{
                        if((self.allPhotos?.count)! > 0){
                            self.collectionView.reloadData()
                        }
                    }
                case .denied, .restricted:
                    break
                case .notDetermined:
                    break
                }
            }
        }
    }
    
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Save from Photos", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //MARK: Setup View
    func setupView(){
        //Setup CollectionView
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        //Register Cell for CollectionView
        collectionView.register(PIPhotoLibraryCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (allPhotos?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PIPhotoLibraryCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPhotoLibraryCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        let asset = self.allPhotos[(indexPath as NSIndexPath).item]
        self.imageManager.requestImage(for: asset,
                                        targetSize: CGSize(width:100, height:100),
                                        contentMode: .aspectFill,
                                        options: nil) {
                                            result, info in
                                            if cell.tag == currentTag {
                                                cell.image = result
                                            }
        }
        
        return cell
    }

    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let asset = self.allPhotos[(indexPath as NSIndexPath).item]
        
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        self.imageManager.requestImage(for: asset,
                                       targetSize: PHImageManagerMaximumSize,
                                       contentMode: .aspectFill,
                                       options: options) {
                                        result, info in
                                        //Show Create Pin Controller
                                        let createPinVC = CreatePinController()
                                        let navVC = NavigationController.init(rootViewController: createPinVC)
                                        createPinVC.pinImage = result
                                        self.present(navVC, animated: true, completion: nil)
        }
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}

