//
//  PISearchBar.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/16/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class PISearchBar: UISearchBar{
    
    var preferredFont: UIFont!
    var preferredTextColor: UIColor!
    var preferredBackgroundColor: UIColor!
    
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            //Access SearchBar TextField
            let searchField: UITextField = (subviews[0] ).subviews[index] as! UITextField
            //Customize SearchBar TextField
            searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10.0, height: frame.size.height - 10.0)
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            searchField.backgroundColor = preferredBackgroundColor
        }
        
        super.draw(rect)
    }

    init(frame: CGRect, font: UIFont, textColor: UIColor, tintColor: UIColor, bgColor: UIColor) {
        super.init(frame: frame)
        
        //Setup SearchBar
        self.frame = frame
        self.searchBarStyle = .default
        self.isTranslucent = false
        self.tintColor = tintColor
        self.barTintColor = UIColor.white
        self.backgroundColor = UIColor.white

        preferredFont = font
        preferredTextColor = textColor
        preferredBackgroundColor = bgColor
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Find Index of SearchBar in Subviews
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self){
                index = i
                break
            }
        }
        
        return index
    }
    
    //Set Placeholder permenantly on the left
    override public var placeholder:String? {
        didSet {
            if #available(iOS 9.0, *) {
                if let text = placeholder {
                    if text.characters.last! != " " {
                        let attr = UITextField.appearance(whenContainedInInstancesOf: [PISearchBar.self]).defaultTextAttributes
                        let maxSize = CGSize(width: self.bounds.size.width - 140, height: 40)
                        let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        let spaces = floor((maxSize.width - widthText) / widthSpace)
                        let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
                        if newText != text {
                            placeholder = newText
                        }
                    }
                }
            }
        }
    }
    
}
