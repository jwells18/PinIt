//
//  CreateBoardController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/18/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class CreateBoardController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    private var tableView: UITableView!
    private var cellIdentifier = "cell"
    private var createBtn: UIButton!
    private var createButton: UIBarButtonItem!
    private var boardNameString = String()
    private var isModal = Bool()
    
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
        //Show Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
        //Determine isModal
        isModal = isModalVC()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override var prefersStatusBarHidden: Bool {
        //Show Status Bar
        return false
    }
    
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Create board", comment: "")

        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Setup Navigation Items
        createBtn = UIButton.init(type: .custom)
        createBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 35)
        createBtn.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
        createBtn.setTitleColor(UIColor.white, for: .normal)
        createBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createBtn.addTarget(self, action: #selector(self.createButtonPressed), for: .touchUpInside)
        createBtn.backgroundColor = PIColor.faintGray
        createBtn.layer.cornerRadius = 2
        createBtn.clipsToBounds = true
        createBtn.isEnabled = false
        createButton = UIBarButtonItem(customView: createBtn)
        self.navigationItem.rightBarButtonItem = createButton
    }
    
    func setupView(){
        //Setup Board TableView
        self.setupTableView()
    }
    
    func setupTableView(){
        tableView = UITableView(frame: CGRect(x: 15, y: 0, width: w-30, height: h))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        tableView.register(PIInputCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PIInputCell
        cell.selectionStyle = .none
        
        cell.textFieldLabel.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: 20)
        cell.textField.frame = CGRect(x: 0, y: 20, width: cell.frame.width, height: 75)
        cell.textField.textColor = UIColor.darkGray
        cell.textField.font = UIFont.boldSystemFont(ofSize: 26)
        cell.textField.tintColor = PIColor.primary
        cell.textField.autocapitalizationType = .none
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        cell.textFieldLabel.text = NSLocalizedString("Board name", comment: "")
        cell.textField.placeholder = NSLocalizedString("Add", comment: "")
        cell.textField.becomeFirstResponder()
        
        return cell
    }
    
    //TextField Delegates
    func textFieldDidChange(textField: UITextField) {
        if(textField.placeholder == NSLocalizedString("Add", comment: "")) {
            boardNameString = textField.text!
        }
        
        //Validate Email & Password
        if(boardNameString.characters.count > 0){
            //Enable Create Button
            createBtn.isEnabled = true
            createBtn.backgroundColor = PIColor.primary
            createBtn.setTitleColor(UIColor.white, for: .normal)
            createButton = UIBarButtonItem(customView: createBtn)
            self.navigationItem.rightBarButtonItem = createButton
        }
        else{
            //Disable Create Button
            createBtn.isEnabled = false
            createBtn.backgroundColor = PIColor.faintGray
            createBtn.setTitleColor(UIColor.darkGray, for: .normal)
            createButton = UIBarButtonItem(customView: createBtn)
            self.navigationItem.rightBarButtonItem = createButton
        }
    }
    
    //BarButtonItem Delegates
    func backButtonPressed(){
        self.dismissVC()
    }

    func dismissVC(){
        switch (isModal){
        case true:
            self.dismiss(animated: true, completion: nil)
            break
        case false:
            _ = self.navigationController?.popViewController(animated: true)
            break
        }
    }
    
    func createButtonPressed(){
        //Create New Board
        let board = Board()
        board.name = boardNameString
        
        let boardManager = BoardManager()
        self.dismissVC()
        boardManager.create(board: board) { (completed: Bool) in
            if(completed){
                //Show Upload Message
                let toastDict:[String: Any] = ["message": NSLocalizedString("Created Board!", comment: "")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
            }
            else{
                //Show Error Message
                let toastDict:[String: Any] = ["message": NSLocalizedString("Error creating board", comment: "")]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
            }
        }
    }
    
    //Other Functions
    func isModalVC() -> Bool{
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        if((self.presentingViewController) != nil){
            let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .plain, target: self, action: #selector(self.backButtonPressed))
            self.navigationItem.leftBarButtonItem = cancelButton
            return true
        }
        if(self.navigationController?.presentingViewController?.presentedViewController == self.navigationController){
            let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .plain, target: self, action: #selector(self.backButtonPressed))
            self.navigationItem.leftBarButtonItem = cancelButton
            return true
        }
        if(self.tabBarController?.presentingViewController?.isKind(of: UITabBarController.self))!{
            let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .plain, target: self, action: #selector(self.backButtonPressed))
            self.navigationItem.leftBarButtonItem = cancelButton
            return true
        }
        
        return false
    }
}
