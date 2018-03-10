//
//  Constants.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/11/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

//View Dimensions
let screenBounds = UIScreen.main.bounds
let screenSize   = screenBounds.size
let w = screenSize.width
let h = screenSize.height

//UI Object Dimensions
let gridWidth : CGFloat = (screenSize.width/2)-45.0
let navigationHeight: CGFloat = 44.0
let statusBarHeight: CGFloat = 20.0
let navigationHeaderAndStatusbarHeight : CGFloat = navigationHeight + statusBarHeight
let searchBarFontSize = CGFloat(16)

//Database Constants
var userDatabase = "User"
var userPrimaryKey = "objectId"
var boardDatabase = "Boards"
var boardPrimaryKey = "objectId"
var pinDatabase = "Pins"
var pinPrimaryKey = "objectId"
var notificationDatabase = "Notifications"
var notificationPrimaryKey = "objectId"
var discoverPinDatabase = "DiscoverPins"
var peopleToFollowLimit = UInt(10)
var paginationLimit = UInt(15)
var paginationUpperLimit = 150
var discoverSectionTitles = ["Trending", "Holiday & party", "DIY", "Education", "Design", "Home", "Food", "Women's style", "Men's style", "Beauty", "Humor", "Travel", "Shopping"];
var samplePinImages = [UIImage(named: "fashion1"), UIImage(named: "cooking1"), UIImage(named: "fitness1"),UIImage(named: "inspiration1"), UIImage(named: "crafts1"), UIImage(named: "fashion2"), UIImage(named: "cooking2"), UIImage(named: "inspiration2")]
var collectionViewHeights = [1.75, 1.5, 2, 1.25]

//User
var currentUser = Auth.auth().currentUser
var currentDBUser = getCurrentDBUser()
func getCurrentDBUser() -> DBUser?{
    let userManager = UserManager()
    return userManager.loadUser(uid: (currentUser?.uid)!)
}

//Custom Colors
struct PIColor{
    static let primary = UIColorFromRGB(0xC92228)
    static let faintGray = UIColor(white: 0.95, alpha: 1)
    static let facebookBlue = UIColorFromRGB(0x3B5998)
    static let googleBlue = UIColorFromRGB(0x4285F4)
    static let orange = UIColorFromRGB(0xFF9500)
    static let secureGreen = UIColorFromRGB(0x27AE60)
}

public func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//Notification Keys
var presentToastNotification = NSLocalizedString("PresentToastNotification", comment: "")
var refreshProfileVCNotification = NSLocalizedString("RefreshProfileVCNotification", comment: "")

//MARK: Helpers
public func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

public func dateFromDouble(double: Double) -> Date{
    let timeInterval: TimeInterval = double
    let date = Date.init(timeIntervalSince1970: timeInterval/1000)
    return date
}

public func currentTimestamp() -> Double{
    let timestamp = Date().timeIntervalSince1970*1000
    return Double(timestamp)
}

public func downloadImage(url: URL, completion: @escaping (UIImage?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        completion(UIImage(data:data!), response, error)
        }.resume()
}

public func createDefaultCollectionViewFlowLayout() -> UICollectionViewFlowLayout{
    //Setup CollectionView Flow Layout
    let flowLayout = UICollectionViewFlowLayout()
    let itemSize = CGSize(width: w, height: h-navigationHeaderAndStatusbarHeight)
    flowLayout.itemSize = itemSize
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .horizontal
    return flowLayout
}

//Feature Not Available
public func featureUnavailableAlert() -> UIAlertController{
    //Show Alert that this feature is not available
    let alert = UIAlertController(title: NSLocalizedString("Sorry", comment:""), message: NSLocalizedString("This feature is not available yet.", comment:""), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    return alert
}

//Class Name Extension
extension UIViewController {
    var className: String {
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
}

