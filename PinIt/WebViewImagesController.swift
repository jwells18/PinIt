//
//  WebViewImagesController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 3/8/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftLinkPreview

class WebViewImagesController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var currentWebString: String!
    private var cellIdentifier = "cell"
    private var images: [String]!
    private var activityIndicator = UIActivityIndicatorView()
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
        
        //Setup ActivityIndicator
        activityIndicator.activityIndicatorViewStyle = .gray
        collectionView.backgroundView = activityIndicator
        
        //DownloadData
        self.downloadData()
        
        //Setup View
        self.setupView()
    }
    
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Pick Image", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //Download Data
    func downloadData(){
        //Start Activity Indicator
        activityIndicator.startAnimating()
        let slp = SwiftLinkPreview(session:  URLSession.shared,
                                   workQueue: SwiftLinkPreview.defaultWorkQueue,
                                   responseQueue: DispatchQueue.main,
                                   cache: DisabledCache.instance)
        
        slp.preview(currentWebString,
                    onSuccess: {
                        result in
                        self.activityIndicator.stopAnimating()
                        self.images = result[.images] as? [String]
                        self.collectionView.reloadData()
                    },
                    onError: {
                        error in
                        self.activityIndicator.stopAnimating()
                    })
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
        return (images?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PIPhotoLibraryCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPhotoLibraryCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        let image = self.images[(indexPath as NSIndexPath).item]
        cell.imageView.sd_setImage(with: URL(string: image), completed: nil)
        
        return cell
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let cell = collectionView.cellForItem(at: indexPath) as! PIPhotoLibraryCell
        let image = cell.imageView.image
        
        //Show Create Pin Controller
        let createPinVC = CreatePinController()
        let navVC = NavigationController.init(rootViewController: createPinVC)
        createPinVC.pinImage = image
        self.present(navVC, animated: true, completion: nil)
    }

    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}
