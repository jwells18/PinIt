//
//  UserManager.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/25/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class UserManager: NSObject{
    var ref: DatabaseReference!
    
    func create(user: User?, completionHandler:@escaping (Bool) -> Void) {
        //Save User
        ref = Database.database().reference()
        var userData = Dictionary<String, Any>()
        userData["objectId"] = currentUser?.uid
        userData["createdAt"] = ServerValue.timestamp()
        userData["updatedAt"] = ServerValue.timestamp()
        userData["displayName"] = user?.displayName
        userData["username"] = user?.username
        userData["image"] = user?.image
        userData["about"] = user?.about
        userData["location"] = user?.location
        userData["website"] = user?.website
        userData["followerCount"] = 0
        userData["followingCount"] = 0
        ref.child(userDatabase).child((currentUser?.uid)!).child((currentUser?.uid)!).setValue(userData) { (error:Error?, DatabaseReference) in
            if((error) != nil){
                completionHandler(false)
            }
            else{
                completionHandler(true)
            }
        }
    }
    
    func downloadUser(uid: String, completionHandler:@escaping (DBUser?, Bool?, NSDictionary?) -> Void){
        ref = Database.database().reference().child(userDatabase).child(uid).child(uid)
        self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            let rawData = snapshot.value as? NSDictionary
            let user = self.createUser(rawData: rawData)
            let isFollowing = self.determineIfFollowing(rawData: rawData)
            completionHandler(user, isFollowing, rawData)
        })
    }
    
    //Download Users
    func downloadUsers(uids: [String]?, completionHandler:@escaping ([DBUser]?, [Bool]?) -> Void){
        //TODO: Limit query to users who match from uid array. Currently returns all users (easier to implement if database is changed to Firestore (still in beta as on March 2018)
        var users = [DBUser]()
        var isFollowingArray = [Bool]()
        ref = Database.database().reference().child(userDatabase)
        var query = DatabaseQuery()
        query = ref.queryOrderedByKey().queryLimited(toFirst: paginationLimit)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            
            for child in snapshot.children{
                let childSnapshot = child as? DataSnapshot
                let rawDataDict = childSnapshot?.value as! NSDictionary
                let rawDataArray = rawDataDict.allValues
                let rawData = rawDataArray.first as! NSDictionary?
                let user = self.createUser(rawData: rawData)
                let isFollowing = self.determineIfFollowing(rawData: rawData)
                if(user?.objectId != currentDBUser?.objectId){
                    users.insert(user!, at: 0)
                    isFollowingArray.insert(isFollowing, at: 0)
                }
            }
            completionHandler(users, isFollowingArray)
        })
    }
    
    //Download People to Follow
    func downloadPeopleToFollow(completionHandler:@escaping ([DBUser]?, [Bool]?) -> Void){
        //TODO: Download People Randomly. Currently downloads users ordered by key.
        var users = [DBUser]()
        var isFollowingArray = [Bool]()
        ref = Database.database().reference().child(userDatabase)
        var query = DatabaseQuery()
        query = ref.queryOrderedByKey().queryLimited(toFirst: peopleToFollowLimit)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
        
            for child in snapshot.children{
                let childSnapshot = child as? DataSnapshot
                let rawDataDict = childSnapshot?.value as! NSDictionary
                let rawDataArray = rawDataDict.allValues
                let rawData = rawDataArray.first as! NSDictionary?
                let user = self.createUser(rawData: rawData)
                let isFollowing = self.determineIfFollowing(rawData: rawData)
                if(user?.objectId != currentDBUser?.objectId){
                    users.insert(user!, at: 0)
                    isFollowingArray.insert(isFollowing, at: 0)
                }
            }
            completionHandler(users, isFollowingArray)
        })
    }
    
    func determineIfFollowing(rawData: NSDictionary?) -> Bool{
        let followingIdsDict = rawData?["followerIds"] as? NSDictionary
        if(followingIdsDict?[currentDBUser?.objectId ?? ""] != nil){
            return true
        }
        else{
            return false
        }
    }
    
    func createUser(rawData: NSDictionary?) -> DBUser?{
        let user = DBUser()
        user.objectId = rawData?.object(forKey: "objectId") as? String ?? ""
        user.createdAt = rawData?.object(forKey: "createdAt") as! Double
        user.updatedAt = rawData?.object(forKey: "updatedAt") as! Double
        user.displayName = rawData?.object(forKey: "displayName") as? String ?? ""
        user.username = rawData?.object(forKey: "username") as? String ?? ""
        user.image = rawData?.object(forKey: "image") as? String ?? ""
        user.about = rawData?.object(forKey: "about") as? String ?? ""
        user.location = rawData?.object(forKey: "location") as? String ?? ""
        user.website = rawData?.object(forKey: "website") as? String ?? ""
        user.images = rawData?.object(forKey: "images") as? String ?? ""
        user.followerCount = rawData?.object(forKey: "followerCount") as! Int
        user.followingCount = rawData?.object(forKey: "followingCount") as! Int
        return user
    }
    
    func loadUser(uid: String) -> DBUser?{
        //Load User from Realm
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "objectId = %@", uid)
        let dbUser = realm.objects(DBUser.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false).first
        return dbUser
    }
    
    func loadUser(uid: String, completionHandler:@escaping (DBUser) -> Void){
        //Load User from Realm
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "objectId = %@", uid)
        var dbUser = realm.objects(DBUser.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false).first
        if(dbUser != nil){
            completionHandler(dbUser!)
        }
        else{
            dbUser = DBUser()
            completionHandler(dbUser!)
        }
    }
    
    func setProfilePicture(image: UIImage){
        //Convert Image to Data
        let imageData = UIImagePNGRepresentation(image)
        //Save Profile Picture
        let storageRef = Storage.storage().reference()
        _ = storageRef.child(userDatabase).child((currentUser?.uid)!).child("profilePicture").putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL: URL = metadata.downloadURL()!
            //Update User Object
            self.ref = Database.database().reference().child(userDatabase).child((currentUser?.uid)!).child((currentUser?.uid)!)
            self.ref.updateChildValues(["image": downloadURL.absoluteString, "updatedAt": ServerValue.timestamp()])
        }
    }
    
    func updateUser(image: String){
        ref = Database.database().reference().child(userDatabase).child((currentDBUser?.objectId)!).child((currentDBUser?.objectId)!)
        self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            
            let user = snapshot.value as! NSDictionary
            var userPinImages = user["images"] as? String
            //Convert string of recent images to Array
            var userPinImageArray = [String]()
            if(userPinImages != nil){
                userPinImageArray = (userPinImages?.components(separatedBy: ","))!
            }
            //Insert new Image string
            userPinImageArray.insert(image, at: 0)
            //Limit Board Images to 5
            userPinImageArray = Array(userPinImageArray.prefix(3))
            //Convert Array back to string
            userPinImages = userPinImageArray.joined(separator: ",")
            //Update User
            self.ref.updateChildValues(["images": userPinImages!, "updatedAt": ServerValue.timestamp()])
        })
    }
    
    //MARK: Following
    func followUser(uid: String){
        let currentUserId = (currentDBUser?.objectId)!
        ref = Database.database().reference()
        ref.child(userDatabase).child(uid).child(uid).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            //Update Block
            var user = currentData.value as? [String : AnyObject]
            //Add my Id to other user's followers and increase their followers count
            var followerIds = user?["followerIds"] as? Dictionary<String, Any>
            if(followerIds != nil){
                followerIds?[currentUserId] = currentUserId
            }
            else{
                followerIds = [currentUserId: currentUserId]
            }
            
            var followerCount = user?["followerCount"] as? Int ?? 0
            followerCount += 1
            
            user?["followerIds"] = followerIds as AnyObject?
            user?["followerCount"] = followerCount as AnyObject?
            user?["updatedAt"] = ServerValue.timestamp() as AnyObject?
            // Set value and report transaction success
            currentData.value = user
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        
        ref.child(userDatabase).child(currentUserId).child(currentUserId).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            //Update Block
            var user = currentData.value as? [String : AnyObject]
            //Add other user's Id to my following and increase my following count
            var followingIds = user?["followingIds"] as? Dictionary<String, Any>
            if(followingIds != nil){
                followingIds?[uid] = uid
            }
            else{
                followingIds = [uid: uid]
            }

            var followingCount = user?["followingCount"] as? Int ?? 0
            followingCount += 1
            
            user?["followingIds"] = followingIds as AnyObject?
            user?["followingCount"] = followingCount as AnyObject?
            user?["updatedAt"] = ServerValue.timestamp() as AnyObject?
            // Set value and report transaction success
            currentData.value = user
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        
    }
    
    func unfollowUser(uid: String){
        let currentUserId = (currentDBUser?.objectId)!
        ref = Database.database().reference()
        ref.child(userDatabase).child(uid).child(uid).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            //Update Block
            var user = currentData.value as? [String : AnyObject]
            //Add my Id to other user's followers and increase their followers count
            var followerIds = user?["followerIds"] as? Dictionary<String, Any>
            followerIds?[currentUserId] = nil
            
            var followerCount = user?["followerCount"] as? Int ?? 0
            followerCount -= 1
            
            user?["followerIds"] = followerIds as AnyObject?
            user?["followerCount"] = followerCount as AnyObject?
            user?["updatedAt"] = ServerValue.timestamp() as AnyObject?
            // Set value and report transaction success
            currentData.value = user
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        
        ref.child(userDatabase).child(currentUserId).child(currentUserId).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            //Update Block
            var user = currentData.value as? [String : AnyObject]
            //Add other user's Id to my following and increase my following count
            var followingIds = user?["followingIds"] as? Dictionary<String, Any>
            followingIds?[uid] = nil
            
            var followingCount = user?["followingCount"] as? Int ?? 0
            followingCount -= 1
            
            user?["followingIds"] = followingIds as AnyObject?
            user?["followingCount"] = followingCount as AnyObject?
            user?["updatedAt"] = ServerValue.timestamp() as AnyObject?
            // Set value and report transaction success
            currentData.value = user
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
}

extension UserManager{
    
    func createDataObservers(){
        //Create Database Observers
        if(currentUser != nil){
            if (ref == nil){
                self.createObservers()
            }
        }
    }
    
    func createObservers(){
        ref = Database.database().reference(withPath: userDatabase).child((currentUser?.uid)!)
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            let rawData = snapshot.value as! NSDictionary
            if(rawData["updatedAt"] != nil){
                self.updateRealm(rawData: rawData)
            }
        })
        
        ref.observe(.childChanged, with: { (snapshot) -> Void in
            let rawData = snapshot.value as! NSDictionary
            if(rawData["updatedAt"] != nil){
                self.updateRealm(rawData: rawData)
            }
        })
    }
    
    func updateRealm(rawData: NSDictionary){
        let realm = try! Realm()
        try! realm.write {
            //Remove Following Data (does not conform to Realm available data types)
            let rawMutableData = rawData.mutableCopy() as! NSMutableDictionary
            rawMutableData.removeObject(forKey: "followingIds")
            rawMutableData.removeObject(forKey: "followerIds")
            realm.create(DBUser.self, value: rawMutableData, update: true)
        }
    }
}
