//
//  OrganizeBoardController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import RealmSwift

class OrganizeBoardController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var pins: Array<DBPin>!
    private var cellIdentifier = "cell"

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
    
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Organize", comment: "")
        
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
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.register(PIPinCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.view.addSubview(collectionView)
    }
    
    //MARK: CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Pins CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIPinCell
        if(pins.count > 0){
            //Configure Pin Cells
            let pin = pins[indexPath.item]
            cell.configure(dbPin: pin)
        }
        
        return cell
    }
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){

    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let pin = pins[sourceIndexPath.item]
        pins.remove(at: sourceIndexPath.item)
        pins.insert(pin, at: destinationIndexPath.item)
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}

