//
//  SettingsController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/12/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Firebase
import STPopup

class SettingsController: UIViewController, UITableViewDataSource, UITableViewDelegate, GetHelpPopupDelegate{
    
    private let cellIdentifier = "cell"
    private var tableView = UITableView()
    private var sectionTitles0 = ["Edit profile", "Edit settings"]
    private var sectionTitles1 = ["See order history", "Edit payment method"]
    private var sectionTitles2 = ["Get help", "See terms and privacy", "Personalized ads"]
    private var sectionTitles3 = ["Log out"]
    
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
        self.navigationItem.title = "Settings"
        
        //Setup Navigation Items
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(SettingsController.backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        //Remove Gray Hairline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //Setup View
    func setupView(){
        //Setup TableView
        self.setupTableView()
    }
    
    func setupTableView(){
        //Setup TableView
        tableView = UITableView(frame: CGRect(x:0, y:0, width:w, height:h-navigationHeaderAndStatusbarHeight), style:UITableViewStyle.grouped)
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section){
        case 0:
            return 1
        default:
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return sectionTitles0.count
        case 1:
            return sectionTitles1.count
        case 2:
            return sectionTitles2.count
        case 3:
            return sectionTitles3.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22);
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        switch(indexPath.section){
        case 0:
            cell.textLabel?.text = sectionTitles0[indexPath.row]
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        case 1:
            cell.textLabel?.text = sectionTitles1[indexPath.row]
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        case 2:
            cell.textLabel?.text = sectionTitles2[indexPath.row]
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        case 3:
            cell.textLabel?.text = sectionTitles3[indexPath.row]
            cell.textLabel?.textColor = UIColor.lightGray
            return cell
        default:
            return cell
        }
    }
    
    //TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        case 0:
            switch(indexPath.row){
            case 0:
                //Edit Profile
                let editProfileVC = EditProfileController()
                editProfileVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(editProfileVC, animated: true)
                break
            case 1:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            default:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            }
        case 1:
            switch(indexPath.row){
            case 0:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            case 1:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            case 2:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            default:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            }
        case 2:
            switch(indexPath.row){
            case 0:
                //Get Help
                let popupVC = GetHelpPopupController()
                popupVC.contentSizeInPopup = CGSize(width: w, height: 103)
                popupVC.getHelpPopupDelegate = self
                let popupController = STPopupController.init(rootViewController: popupVC)
                popupController.style = .bottomSheet
                STPopupNavigationBar.appearance().barTintColor = UIColor.white
                STPopupNavigationBar.appearance().tintColor = UIColor.lightGray
                STPopupNavigationBar.appearance().barStyle = .default
                STPopupNavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.darkGray]
                popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopupVC)))
                popupController.present(in: self)
                break
            case 1:
                //Terms and Privacy
                let webPageVC = PIWebViewController()
                webPageVC.url = NSURL(string: NSLocalizedString("PolicyURL", comment:""))!
                let navVC = NavigationController.init(rootViewController: webPageVC)
                self.present(navVC, animated: true, completion: nil)
                break
            case 2:
                //Personalized Ads
                //Open Url in Safari
                let personalizedAdsUrl = URL(string: NSLocalizedString("PersonalizedAdsURL", comment:""))
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(personalizedAdsUrl!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(personalizedAdsUrl!)
                }
                break
            default:
                self.present(featureUnavailableAlert(), animated: true, completion: nil)
                break
            }
        case 3:
            //Log User Out
            do{
                try Auth.auth().signOut()
            }
            catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            break
        default:
            break
        }
    }
    
    func dismissPopupVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: BarButtonItem Delegates
    func backButtonPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //Popup Delegates
    func didPressVisitHelpCenter(){
        //Show WebViewController with help web address
        let webPageVC = PIWebViewController()
        webPageVC.url = NSURL(string: NSLocalizedString("HelpURL", comment: ""))!
        let navVC = NavigationController.init(rootViewController: webPageVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func didPressContactExpert(){
        //Contact a PinIt expert
        self.present(featureUnavailableAlert(), animated: true, completion: nil)
    }
}
