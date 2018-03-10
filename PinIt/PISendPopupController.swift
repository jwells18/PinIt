//
//  PISendPopupController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/22/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol SendPopupDelegate {
    func didPressChooseFromContacts()
}

class PISendPopupController: UIViewController{
    
    var sendPopupDelegate: SendPopupDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup view
        self.view.backgroundColor = UIColor.white
        
        //Setup NavigationBar
        self.setupNavigationBar()
        
        //Setup View
        self.setupView()
    }
    
    //Setup NavigationBar
    func setupNavigationBar(){
        //Setup NavigationBar
        self.navigationItem.title = NSLocalizedString("Send Pin", comment: "")
        
        //Setup Navigation Items
        let cancelButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .plain, target: self, action: #selector(self.cancelButtonPressed))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    //Setup View
    func setupView(){
        //Setup Choose from Contacts Button
        self.setupChooseFromContactsButton()
    }
    
    func setupChooseFromContactsButton(){
        let chooseFromContactsButton = UIButton(frame: CGRect(x: 15, y: 10, width: w-30, height: 40))
        chooseFromContactsButton.setTitle(NSLocalizedString("Choose from contacts", comment: ""), for: .normal)
        chooseFromContactsButton.setTitleColor(UIColor.white, for: .normal)
        chooseFromContactsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        chooseFromContactsButton.backgroundColor = PIColor.primary
        chooseFromContactsButton.layer.cornerRadius = 5
        chooseFromContactsButton.clipsToBounds = true
        chooseFromContactsButton.addTarget(self, action: #selector(self.chooseFromContactsButtonPressed), for: .touchUpInside)
        self.view.addSubview(chooseFromContactsButton)
    }
    
    //MARK: BarButtonItem Delegates
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //Button Delegates
    func chooseFromContactsButtonPressed(){
        self.dismiss(animated: true) { 
            self.sendPopupDelegate.didPressChooseFromContacts()
        }
    }
}
