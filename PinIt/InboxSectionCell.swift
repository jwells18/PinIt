//
//  InboxSectionCell.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol InboxDelegate {
    func didPressNewMessage()
}

class InboxSectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate, InboxHeaderDelegate{
    
    var inboxDelegate: InboxDelegate!
    var tableViewHeader = InboxHeader()
    private var tableView = UITableView()
    private var refreshControl = UIRefreshControl()
    private var cellIdentifier = "cell"
    private var messages: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Setup TableView
        tableView.frame = CGRect(x: 15, y: 0, width: frame.width-30, height: frame.size.height)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = PIColor.faintGray
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(InboxCell.self, forCellReuseIdentifier: cellIdentifier)
        contentView.addSubview(tableView)
        
        //Setup RefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        //Setup TableView Header
        tableViewHeader.frame = CGRect(x:0, y:0, width:frame.width, height:60)
        tableViewHeader.inboxHeaderDelegate = self
        tableView.tableHeaderView = tableViewHeader
        
        //Download Data
        self.downloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Download Data
    func downloadData(){
        tableView.reloadData()
    }
    
    func refreshData(){
        refreshControl.endRefreshing()
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(messages.count > 0){
            return messages.count
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(messages.count > 0){
            return 50
        }
        else{
            return 260
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InboxCell
        if(messages.count > 0){
            tableView.separatorStyle = .singleLine
            cell.configure()
            return cell
        }
        else{
            tableView.separatorStyle = .none
            cell.configureEmpty()
            return cell
        }
    }
    
    //Button Methods
    func relayDidPressNewMessage(){
        inboxDelegate.didPressNewMessage()
    }
}
