//
//  NotificationCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/12/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import SDWebImage

class NotificationCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    private var headerLabel = UILabel()
    private var images = [String]()
    private var profilePicture = UIImageView()
    private var messageLabel = UILabel()
    private var dateLabel = UILabel()
    private var emptyLabel = UILabel()
    private var cellIdentifier = "cell"
    lazy var collectionView: UICollectionView = {
        //Setup CollectionView Flow Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        //Setup CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 5
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.selectionStyle = .none
        
        //Setup Header Label
        headerLabel.textColor = UIColor.darkGray
        headerLabel.font = UIFont.boldSystemFont(ofSize: 26)
        self.addSubview(headerLabel)
        
        //Setup Profile Picture
        profilePicture.clipsToBounds = true
        profilePicture.isUserInteractionEnabled = false
        profilePicture.backgroundColor = PIColor.faintGray
        self.addSubview(profilePicture)
        
        //Setup Message Label
        messageLabel.textColor = UIColor.darkGray
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(messageLabel)
        
        //Setup Message Date Label
        dateLabel.textColor = UIColor.lightGray
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(dateLabel)
        
        //Setup CollectionView
        collectionView.register(PIImageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.isUserInteractionEnabled = false
        collectionView.backgroundColor = UIColor.white
        self.addSubview(collectionView)
        
        //Setup Empty TableView Label
        emptyLabel.text = NSLocalizedString("Empty Notifications Table", comment: "")
        emptyLabel.textColor = UIColor.darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.numberOfLines = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Set Frames
        headerLabel.frame = CGRect(x: 0, y: 10, width: frame.width, height: 40)
        profilePicture.frame = CGRect(x: 0, y: 10+40+10, width: 40, height: 40)
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        messageLabel.frame = CGRect(x: 40+15, y: 10+40+10, width: frame.width-40-15, height: 40)
        dateLabel.frame = CGRect(x: 40+15, y: 10+40+10+40, width: frame.width-40-15, height: 20)
        collectionView.frame = CGRect(x: 40+15, y: 10+40+10+40+20+5, width: frame.width-40-15, height: 140)
        emptyLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func configure(dbNotification: DBNotification?){
        let date = dateFromDouble(double: (dbNotification?.createdAt)!)
        if(dbNotification?.createdAt != nil){
            headerLabel.text = self.determineDateString(date: date)
        }
        messageLabel.text = dbNotification?.message
        dateLabel.text = date.timeAgoSinceNow
        if(dbNotification?.profilePicture != nil){
            profilePicture.sd_setImage(with: URL(string: (dbNotification?.profilePicture)!), placeholderImage: nil)
        }
        else{
            profilePicture.image = nil
        }
        if(dbNotification?.images != nil){
            images = (dbNotification?.images?.components(separatedBy: ","))!
        }
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
    }
    
    func configureEmpty(){
        //Show Empty Label
        headerLabel.isHidden = true
        profilePicture.isHidden = true
        messageLabel.isHidden = true
        dateLabel.isHidden = true
        collectionView.isHidden = true
        self.backgroundView = emptyLabel
    }
    
    func determineDateString(date: Date) -> String{
        let calendar = NSCalendar.current
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        else if calendar.isDateInToday(date) {
            return "Today"
        }
        else {
            return date.timeAgoSinceNow
        }
    }
    
    //CollectionView DataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellWidth = collectionView.frame.width-5
        let cellHeight = collectionView.frame.height-2
        return CGSize(width: cellWidth/4, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Setup Boards CollectionView
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PIImageCell
        cell.backgroundColor = PIColor.faintGray
        if(images.count > 0 && indexPath.row <= images.count-1){
            cell.configure(image: images[indexPath.row])
        }
        else{
            cell.configure(image: nil)
        }
        return cell
    }

}
