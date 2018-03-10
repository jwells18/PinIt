//
//  AddBoardPinPopupController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/20/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol AddBoardPinPopupDelegate {
    func didPressCreateBoard()
    func didPressPhoto()
    func didPressWebsite()
}

class AddBoardPinPopupController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var addBoardPinPopupDelegate: AddBoardPinPopupDelegate!
    var tableView = UITableView()
    var cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup TableView
        self.setupView()
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Add a board or Pin", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    //Setup View
    func setupView(){
        //Setup TableView
        self.setupTableView()
    }
    
    func setupTableView(){
        //Setup TableView
        tableView = UITableView(frame: CGRect(x:0, y:0, width:w, height:h), style: .grouped)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
    }
    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height:25))
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width-30, height:25))
        headerLabel.textColor = UIColor.darkGray
        headerLabel.font = UIFont.systemFont(ofSize: 14)
        switch(section){
        case 0:
            headerLabel.text = NSLocalizedString("Board", comment: "")
            break
        case 1:
            headerLabel.text = NSLocalizedString("Pin", comment: "")
            break
        default:
            break
        }
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.selectionStyle = .none
        switch(indexPath.section){
        case 0:
            //Board Section
            switch(indexPath.row){
            case 0:
                cell.textLabel?.text = NSLocalizedString("Create board", comment: "")
                break
            default:
                break
            }
        case 1:
            //Pin Section
            switch(indexPath.row){
            case 0:
                //Photo
                cell.textLabel?.text = NSLocalizedString("Photo", comment: "")
                break
            case 1:
                //Website
                cell.textLabel?.text = NSLocalizedString("Website", comment: "")
                break
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    //TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        case 0:
            //Board Section
            switch(indexPath.row){
            case 0:
                self.dismiss(animated: true, completion: { 
                    self.addBoardPinPopupDelegate.didPressCreateBoard()
                })
                break
            default:
                break
            }
        case 1:
            //Pin
            switch(indexPath.row){
            case 0:
                self.dismiss(animated: true, completion: {
                    self.addBoardPinPopupDelegate.didPressPhoto()
                })
                break
            case 1:
                self.dismiss(animated: true, completion: {
                    self.addBoardPinPopupDelegate.didPressWebsite()
                })
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    //MARK: BarButtonItem Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}
