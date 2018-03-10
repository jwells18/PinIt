//
//  DeletePinPopupController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/28/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol DeletePinPopupDelegate{
    func didPressDeletePin()
}

class DeletePinPopupController: UIViewController{
    
    var deletePinPopupDelegate: DeletePinPopupDelegate!
    
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
        //Setup Title Label
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 10, width: w-30, height: 60))
        titleLabel.text = NSLocalizedString("Delete Pin?", comment: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.textColor = UIColor.darkGray
        self.view.addSubview(titleLabel)
        
        //Setup Warning Label
        let warningLabel = UILabel(frame: CGRect(x: 15, y: 10+60+10, width: w-30, height: 60))
        warningLabel.text = NSLocalizedString("You won't be able to get it back.", comment: "")
        warningLabel.font = UIFont.systemFont(ofSize: 16)
        warningLabel.textColor = UIColor.darkGray
        self.view.addSubview(warningLabel)
        
        //Setup Delete Button
        let deletePinButton = UIButton(frame: CGRect(x: 15, y: 10+60+10+60+10, width: w-30, height: 40))
        deletePinButton.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        deletePinButton.setTitleColor(UIColor.darkGray, for: .normal)
        deletePinButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        deletePinButton.backgroundColor = PIColor.faintGray
        deletePinButton.layer.cornerRadius = 5
        deletePinButton.clipsToBounds = true
        deletePinButton.addTarget(self, action: #selector(self.deletePinButtonPressed), for: .touchUpInside)
        self.view.addSubview(deletePinButton)
        
        //Setup Cancel Button
        let cancelButton = UIButton(frame: CGRect(x: 15, y: 10+60+10+60+10+40+10, width: w-30, height: 40))
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.backgroundColor = PIColor.primary
        cancelButton.layer.cornerRadius = 5
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(self.cancelButtonPressed), for: .touchUpInside)
        self.view.addSubview(cancelButton)
    }
    
    //MARK: Button Delegates
    func deletePinButtonPressed(){
        self.dismiss(animated: true) { 
            self.deletePinPopupDelegate.didPressDeletePin()
        }
    }
    
    func cancelButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}

