//
//  PinManager.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/18/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class PinManager: NSObject{
    
    var ref: DatabaseReference!

    func create(pin: Pin, completionHandler:@escaping (Bool, Dictionary<String, Any>) -> Void) {
        //Convert Image to Data
        let imageData = UIImagePNGRepresentation(pin.image)
        //Save Pin Image
        let uuid = UUID().uuidString
        let storageRef = Storage.storage().reference()
        _ = storageRef.child(pinDatabase).child((currentUser?.uid)!).child(uuid).putData(imageData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL: URL = metadata.downloadURL()!
            //Create and Save new Pin
            self.ref = Database.database().reference()
            var pinData = Dictionary<String, Any>()
            pinData["objectId"] = self.ref.childByAutoId().key
            pinData["createdAt"] = ServerValue.timestamp()
            pinData["updatedAt"] = ServerValue.timestamp()
            pinData["image"] = downloadURL.absoluteString
            pinData["imageWidth"] = pin.imageWidth
            pinData["imageHeight"] = pin.imageHeight
            pinData["caption"] = pin.caption
            pinData["website"] = pin.website
            pinData["createdBy"] = currentUser?.uid
            pinData["pinnedBy"] = currentUser?.uid
            pinData["boardId"] = pin.boardId
            self.ref.child(pinDatabase).child((currentUser?.uid)!).child(pinData["objectId"] as! String).setValue(pinData) { (error:Error?, DatabaseReference) in
                if((error) != nil){
                    completionHandler(false, pinData)
                }
                else{
                    completionHandler(true, pinData)
                    //Update Board
                    let boardManager = BoardManager()
                    boardManager.updateBoard(pinData: pinData as NSDictionary)
                    //Update User
                    let userManager = UserManager()
                    userManager.updateUser(image: pinData["image"] as! String)
                }
            }
        }
    }
    
    func loadPins(uid: String?, boardId:String?, completionHandler:@escaping (Results<DBPin>?) -> Void){
        //Load Pins from Realm
        let realm = try! Realm()
        if(uid != nil && boardId != nil){
            let realmPredicate = NSPredicate(format: "pinnedBy = %@ AND boardId = %@", uid!, boardId!)
            let dbPin = realm.objects(DBPin.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false)
            completionHandler(dbPin)
        }
        else if(uid != nil){
            let realmPredicate = NSPredicate(format: "pinnedBy = %@", uid!)
            let dbPin = realm.objects(DBPin.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false)
            completionHandler(dbPin)
        }
        else{
            completionHandler(nil)
        }
    }
    
    func downloadPins(uid: String, completionHandler:@escaping ([DBPin]?) -> Void){
        var pins = [DBPin]()
        ref = Database.database().reference().child(pinDatabase).child(uid)
        var query = DatabaseQuery()
        query = ref.queryOrdered(byChild: "createdAt").queryLimited(toFirst: paginationLimit)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                completionHandler(pins)
                return
            }
            
            for child in snapshot.children{
                //Find Pin for PinId
                let childSnapshot = child as? DataSnapshot
                let rawData = childSnapshot?.value as! NSDictionary
                let pin = self.createPin(rawData: rawData)
                pins.insert(pin, at: 0)
            }
            completionHandler(pins)
        })
    }
    
    func downloadPins(uid: String?, boardId: String?, completionHandler:@escaping ([DBPin]?) -> Void){
        var pins = [DBPin]()
        ref = Database.database().reference().child(pinDatabase).child(uid!)
        var query = DatabaseQuery()
        query = ref.queryOrdered(byChild: "boardId").queryEqual(toValue: boardId).queryLimited(toFirst: paginationLimit)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                completionHandler(pins)
                return
            }
            
            for child in snapshot.children{
                //Find Pin for PinId
                let childSnapshot = child as? DataSnapshot
                let rawData = childSnapshot?.value as! NSDictionary
                let pin = self.createPin(rawData: rawData)
                pins.insert(pin, at: 0)
            }
            completionHandler(pins)
        })
    }
    
    func downloadDiscoverPins(endValue: Double?, completionHandler:@escaping ([DBPin]) -> Void){
        var pins = [DBPin]()
        ref = Database.database().reference().child(discoverPinDatabase)
        var query = DatabaseQuery()
        
        query = ref.queryOrdered(byChild: "createdAt").queryEnding(atValue: endValue).queryLimited(toLast: paginationLimit)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                completionHandler(pins)
                return
            }
            
            for child in snapshot.children{
                //Find Pin for PinId
                let childSnapshot = child as? DataSnapshot
                let rawData = childSnapshot?.value as! NSDictionary
                let pin = self.createPin(rawData: rawData)
                if(pin.createdBy != currentDBUser?.objectId){
                    pins.insert(pin, at: 0)
                }
            }
            completionHandler(pins)
        })
    }
    
    func createPin(rawData: NSDictionary?) -> DBPin{
        let pin = DBPin()
        pin.objectId = rawData?.object(forKey: "objectId") as! String!
        pin.createdAt = rawData?.object(forKey: "createdAt") as! Double
        pin.updatedAt = rawData?.object(forKey: "updatedAt") as! Double
        pin.image = rawData?.object(forKey: "image") as! String!
        pin.imageWidth = rawData?.object(forKey: "imageWidth") as! Float
        pin.imageHeight = rawData?.object(forKey: "imageHeight") as! Float
        pin.caption = rawData?.object(forKey: "caption") as! String!
        pin.website = rawData?.object(forKey: "website") as! String!
        pin.createdBy = rawData?.object(forKey: "createdBy") as! String!
        pin.pinnedBy = rawData?.object(forKey: "pinnedBy") as! String!
        pin.boardId = rawData?.object(forKey: "boardId") as! String!
        return pin
    }
    
    func updatePin(pin: DBPin?, updateDict: Dictionary<String, Any>, completionHandler:@escaping (Error?) -> Void){
        let pinId = pin?.objectId
        let creatorId = pin?.createdBy
        var updatedDict = updateDict
        updatedDict["updatedAt"] = ServerValue.timestamp()
        if(pinId != nil && creatorId != nil){
            ref = Database.database().reference().child(pinDatabase).child(creatorId!).child(pinId!)
            ref.updateChildValues(updatedDict, withCompletionBlock: { (error: Error?, DatabaseReference) in
                if(error != nil){
                    //Update Discover Pin
                    self.ref = Database.database().reference().child(discoverPinDatabase).child((pin?.objectId)!)
                    self.ref.updateChildValues(updateDict)
                    completionHandler(error)
                }
                else{
                    completionHandler(error)
                }
            })
        }
    }
    
    func deletePin(pin: DBPin, completionHandler:@escaping (Error?) -> Void){
        let dbPinObjectId = pin.objectId
        let dbPinBoardId = pin.boardId
        let dbPinImage = pin.image
        ref = Database.database().reference().child(pinDatabase).child((currentDBUser?.objectId)!).child(dbPinObjectId!)
        ref.removeValue { (error: Error?, DatabaseReference) in
            if(error == nil){
                //Remove Pin from Board Images
                self.ref = Database.database().reference().child(boardDatabase).child((currentDBUser?.objectId)!).child(dbPinBoardId!)
                self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !snapshot.exists() { return }
                    //Find Board for BoardId
                    let board = snapshot.value as! NSDictionary
                    var boardImages = board["images"] as? String
                    //Convert string of recent images to Array
                    var boardImageArray = [String]()
                    if(boardImages != nil){
                        boardImageArray = (boardImages?.components(separatedBy: ","))!
                    }
                    //Remove from Image String(if necessary)
                    if(boardImageArray.contains(dbPinImage!)){
                        boardImageArray = boardImageArray.filter { $0 != dbPinImage! }
                        
                        //Convert Array back to string
                        boardImages = boardImageArray.joined(separator: ",")
                        //Update Board
                        self.ref.updateChildValues(["images": boardImages!, "updatedAt": ServerValue.timestamp()])
                    }
                    
                    //Remove Pin from DiscoverPins
                    self.ref = Database.database().reference().child(discoverPinDatabase).child(dbPinObjectId!)
                    self.ref.removeValue()
                    
                    completionHandler(error)
                })
            }
            else{
                completionHandler(error)
            }
        }
    }
}

extension PinManager{
    
    func lastUpdatedAt() -> Double{
        //Return all DBPins from Realm and return most recent updatedAt date
        let realm = try! Realm()
        let pin = realm.objects(DBPin.self).sorted(byKeyPath: "updatedAt", ascending: true).last
        if(pin != nil){
            return (pin?.updatedAt)!
        }
        else{
            return 0
        }
    }
}

extension PinManager{
    
    func createDataObservers(){
        //Create Database Observers
        if(currentUser != nil){
            if (ref == nil){
                self.createObservers()
            }
        }
    }
    
    func createObservers(){
        let lastUpdatedAt = self.lastUpdatedAt()
        let ref = Database.database().reference(withPath: pinDatabase).child((currentUser?.uid)!)
        let query: DatabaseQuery = ref.queryOrdered(byChild: "updatedAt").queryStarting(atValue: lastUpdatedAt+1)
        query.observe(.childAdded, with: { (snapshot) -> Void in
            let rawData = snapshot.value as! NSDictionary
            if(rawData["updatedAt"] != nil){
                self.updateRealm(rawData: rawData)
            }
        })
        
        query.observe(.childChanged, with: { (snapshot) -> Void in
            let rawData = snapshot.value as! NSDictionary
            if(rawData["updatedAt"] != nil){
                self.updateRealm(rawData: rawData)
            }
        })
    }
    
    func updateRealm(rawData: NSDictionary){
        let realm = try! Realm()
        try! realm.write{
            realm.create(DBPin.self, value: rawData, update: true)
        }
    }
    
    func deleteInRealm(dbPin: DBPin){
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "objectId = %@", dbPin.objectId)
        let dbPin = realm.objects(DBPin.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false)
        try! realm.write{
            realm.delete(dbPin)
        }
    }
}
