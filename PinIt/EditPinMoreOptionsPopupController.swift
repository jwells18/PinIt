//
//  EditPinMoreOptionsPopupController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/27/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol EditPinMoreOptionsPopupDelegate {
    func didPressDownloadImage()
    func didPressCopy()
    func didPressReport()
}

class EditPinMoreOptionsPopupController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var editPinMoreOptionsPopupDelegate: EditPinMoreOptionsPopupDelegate!
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
        self.navigationItem.title = NSLocalizedString("More options", comment: "")
        
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
        tableView = UITableView(frame: CGRect(x:0, y:0, width:w, height:h), style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.separatorColor = PIColor.faintGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
    }
    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.selectionStyle = .none
        
        switch(indexPath.row){
        case 0:
            cell.textLabel?.text = NSLocalizedString("Download image", comment: "")
            break
        case 1:
            cell.textLabel?.text = NSLocalizedString("Copy", comment: "")
            break
        case 2:
            cell.textLabel?.text = NSLocalizedString("Report pin", comment: "")
            break
        default:
            break
        }
        
        return cell
    }
    
    //TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0:
            //Download Image
            self.dismiss(animated: true, completion: {
                self.editPinMoreOptionsPopupDelegate.didPressDownloadImage()
            })
            break
        case 1:
            //Copy Image
            self.dismiss(animated: true, completion: {
                self.editPinMoreOptionsPopupDelegate.didPressCopy()
            })
            break
        case 2:
            //Report Pin
            self.dismiss(animated: true, completion: {
                self.editPinMoreOptionsPopupDelegate.didPressReport()
            })
            break
        default:
            break
        }
    }
    
    //MARK: BarButtonItem Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}

