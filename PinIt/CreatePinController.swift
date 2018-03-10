//
//  CreatePinController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/18/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import RealmSwift

class CreatePinController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    var pinImage: UIImage!
    var dbPin: DBPin!
    private var tableView = UITableView()
    private var tableViewHeader = CreatePinHeader()
    private var cellIdentifier = "cell"
    private var boards: Results<DBBoard>!
    private var doneBtn: UIButton!
    private var isEditingDescription = Bool()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Download Data
        self.downloadData()
        
        //Setup View
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Show Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
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
        self.navigationItem.title = NSLocalizedString("Choose board", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named:"cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        doneBtn = UIButton.init(type: .custom)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 35)
        doneBtn.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        doneBtn.addTarget(self, action: #selector(self.doneButtonPressed), for: .touchUpInside)
        doneBtn.backgroundColor = PIColor.primary
        doneBtn.layer.cornerRadius = 2
        doneBtn.clipsToBounds = true
        doneBtn.isHidden = true
        let doneButton = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = doneButton
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func downloadData(){
        //Download Board Data
        let boardManager = BoardManager()
        boardManager.loadBoards(uid: (currentUser?.uid)!, completionHandler: { (boardResults: Results<DBBoard>) in
            self.boards = boardResults
            self.tableView.reloadData()
        })
    }
    
    func setupView(){
        //Setup Board TableView
        self.setupTableView()
    }
    
    func setupTableView(){
        //Setup TableView
        tableView.frame = CGRect(x: 15, y: 0, width: w-30, height: h-navigationHeaderAndStatusbarHeight)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        tableView.register(CreatePinBoardCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
        
        //Setup TableViewHeader
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 125)
        tableViewHeader.configure(image: pinImage, dbPin: dbPin)
        tableViewHeader.pinDescriptionTextView.delegate = self
        tableView.tableHeaderView = tableViewHeader
    }
    
    //TableView Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch isEditingDescription{
        case true:
            return 0
        case false:
            return boards.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CreatePinBoardCell

        if(boards.count > 0 && indexPath.row <= boards.count-1){
            //Configure Board cell
            let board = boards[indexPath.item]
            cell.configure(dbBoard: board)
        }
        else{
            //Configure Create Board cell
            cell.configure(dbBoard: nil)
        }
        
        return cell
    }
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(boards.count > 0 && indexPath.row <= boards.count-1){
            //Create Pin
            let board = boards[indexPath.item]
            let pin = Pin()
            var image: UIImage!
            if(pinImage != nil){
                image = pinImage
            }
            else if(dbPin.image != nil){
                image = tableViewHeader.pinImageView.image!
            }
            pin.image = image
            pin.imageWidth = Float((image?.size.width)!)
            pin.imageHeight = Float((image?.size.height)!)
            pin.caption = tableViewHeader.pinDescriptionTextView.text
            pin.boardId = board.objectId
            let pinManager = PinManager()
            pinManager.create(pin: pin, completionHandler: { (completed: Bool, rawData: Dictionary<String, Any>) in
                if(completed){
                    //Show Upload Message
                    let toastDict:[String: Any] = ["message": String(format: "%@ %@",NSLocalizedString("Saved to", comment: ""), board.name), "image": rawData["image"] as! String]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
                else{
                    //Show Error Message
                    let toastDict:[String: Any] = ["message": String(format: "%@ %@",NSLocalizedString("Error saving to", comment: ""), board.name)]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: presentToastNotification), object: nil, userInfo: toastDict)
                }
            })
            self.dismiss(animated: true, completion: nil)
        }
        else{
            //Show Create Board Controller
            let createBoardVC = CreateBoardController()
            self.navigationController?.pushViewController(createBoardVC, animated: true)
        }
    }
    
    //TextView Delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneBtn.isHidden = false
        isEditingDescription = true
        tableView.reloadData()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        doneBtn.isHidden = true
        isEditingDescription = false
        tableView.reloadData()
    }
    
    //BarButton Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed(){
        //Resign Pin Description TextView
        tableViewHeader.pinDescriptionTextView.resignFirstResponder()
        
        //Show TableView
        isEditingDescription = false
        tableView.reloadData()
    }
}
