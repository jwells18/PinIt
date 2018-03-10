//
//  GetHelpPopupController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol GetHelpPopupDelegate {
    func didPressVisitHelpCenter()
    func didPressContactExpert()
}

class GetHelpPopupController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var getHelpPopupDelegate: GetHelpPopupDelegate!
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
        self.navigationItem.title = NSLocalizedString("Get Help", comment: "")
        
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
        return 2
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
            cell.textLabel?.text = NSLocalizedString("Visit the help center", comment: "")
            break
        case 1:
            cell.textLabel?.text = NSLocalizedString("Contact a PinIt expert", comment: "")
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
            self.dismiss(animated: true, completion: {
                self.getHelpPopupDelegate.didPressVisitHelpCenter()
            })
            break
        case 1:
            self.dismiss(animated: true, completion: {
                self.getHelpPopupDelegate.didPressContactExpert()
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
