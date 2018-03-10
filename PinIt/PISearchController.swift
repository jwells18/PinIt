//
//  PISearchController.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/16/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

protocol PISearchControllerDelegate {
    func didStartSearching()
    func didEndSearching()
    func didTapOnSearchButton()
    func didTapOnCancelButton()
    func didTapOnBookmarkButton()
    func didChangeSearchText(searchText: String)
}

class PISearchController: UISearchController, UISearchBarDelegate{
    
    var customSearchBar: PISearchBar!
    var customDelegate: PISearchControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Setup Search Controller
    init(searchResultsController: UIViewController!, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor, searchBarBackgroundColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        
        self.dimsBackgroundDuringPresentation = false
        configureSearchBar(frame: searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, tintColor:searchBarTintColor, bgColor: searchBarBackgroundColor)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //Setup SearchBar
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, tintColor: UIColor, bgColor: UIColor) {
        customSearchBar = PISearchBar(frame: frame, font: font, textColor: textColor, tintColor: tintColor, bgColor: bgColor)
        customSearchBar.placeholder = NSLocalizedString("Search", comment: " ")
        customSearchBar.setImage(UIImage(named:"camera"), for: .bookmark, state: .normal)
        customSearchBar.showsBookmarkButton = true
        customSearchBar.showsCancelButton = false
        customSearchBar.translatesAutoresizingMaskIntoConstraints = false
        customSearchBar.delegate = self
    }
    
    //SearchBar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        customDelegate.didStartSearching()
        self.customSearchBar.showsCancelButton = true
        self.customSearchBar.showsBookmarkButton = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        customDelegate.didEndSearching()
        self.customSearchBar.showsCancelButton = false
        self.customSearchBar.showsBookmarkButton = true
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        customDelegate.didTapOnBookmarkButton()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnCancelButton()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        customDelegate.didChangeSearchText(searchText: searchText)
    }

}
