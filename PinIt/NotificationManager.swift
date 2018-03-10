//
//  NotificationManager.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/27/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import RealmSwift

class NotificationManager: NSObject{
    
    var ref: DatabaseReference!
    
    func loadNotifications(uid: String, completionHandler:@escaping (Results<DBNotification>?) -> Void){
        //Load Notifications from Realm
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "recipientId = %@", uid)
        let dbNotification = realm.objects(DBNotification.self).filter(realmPredicate).sorted(byKeyPath: "createdAt", ascending: false)
        
        completionHandler(dbNotification)
    }
}

extension NotificationManager{
    
    func lastUpdatedAt() -> Double{
        //Return all DBNotifications from Realm and return most recent updatedAt date
        let realm = try! Realm()
        let notification = realm.objects(DBNotification.self).sorted(byKeyPath: "updatedAt", ascending: true).last
        if(notification != nil){
            return (notification?.updatedAt)!
        }
        else{
            return 0
        }
    }
}

extension NotificationManager{
    
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
        let ref = Database.database().reference(withPath: notificationDatabase).child((currentUser?.uid)!)
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
            realm.create(DBNotification.self, value: rawData, update: true)
        }
    }
}
