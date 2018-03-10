//
//  NotificationsSectionCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import RealmSwift

protocol NotificationDelegate {
    func didPressNotificationCell(notification: DBNotification?)
}

class NotificationsSectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate{
    
    var notificationDelegate: NotificationDelegate!
    private var tableView = UITableView()
    private var refreshControl = UIRefreshControl()
    private var cellIdentifier = "cell"
    private var notifications: Results<DBNotification>!
    private var activityIndicator = UIActivityIndicatorView()
    private var isInitialDownload = Bool()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Setup TableView
        tableView.frame = CGRect(x: 15, y: 0, width: frame.width-30, height: frame.height)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = PIColor.faintGray
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(NotificationCell.self, forCellReuseIdentifier: cellIdentifier)
        contentView.addSubview(tableView)
        
        //Setup RefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.downloadData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        //Download Data
        isInitialDownload = true
        self.downloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Download Data
    func downloadData(){
        //Download Pin Data
        let notificationManager = NotificationManager()
        notificationManager.loadNotifications(uid: (currentUser?.uid)!) { (notificationResults: Results<DBNotification>?) in
            self.notifications = notificationResults
            self.isInitialDownload = false
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if((notifications?.count ?? 0) > 0){
            return (notifications?.count ?? 1)
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationCell
        if(notifications.count > 0){
            //Configure Pin Cells
            tableView.separatorStyle = .singleLine
            let notification = notifications[indexPath.item]
            cell.configure(dbNotification: notification)
        }
        else{
            switch isInitialDownload{
            case true:
                //Do not configure
                tableView.separatorStyle = .none
                break
            case false:
                tableView.separatorStyle = .none
                cell.configureEmpty()
            }
        }
        return cell
    }
    
    //TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(notifications.count > 0){
            let notification = notifications[indexPath.item]
            notificationDelegate.didPressNotificationCell(notification: notification)
        }
    }

}
