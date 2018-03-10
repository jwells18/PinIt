//
//  BoardManager.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/18/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import RealmSwift

class BoardManager: NSObject{
    
    var ref: DatabaseReference!
    
    func create(board: Board, completionHandler:@escaping (Bool) -> Void) {
        //Save Board
        ref = Database.database().reference()
        var boardData = Dictionary<String, Any>()
        boardData["objectId"] = ref.childByAutoId().key
        boardData["createdAt"] = ServerValue.timestamp()
        boardData["updatedAt"] = ServerValue.timestamp()
        boardData["name"] = board.name
        boardData["images"] = board.images
        boardData["createdBy"] = currentUser?.uid
        ref.child(boardDatabase).child((currentUser?.uid)!).child(boardData["objectId"] as! String).setValue(boardData) { (error:Error?, DatabaseReference) in
            if((error) != nil){
                completionHandler(false)
            }
            else{
                completionHandler(true)
            }
        }
    }
    
    func loadBoards(uid: String, completionHandler:@escaping (Results<DBBoard>) -> Void){
        //Load Boards from Realm
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "createdBy = %@", uid)
        let dbBoard = realm.objects(DBBoard.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false)
        completionHandler(dbBoard)
    }
    
    func loadBoard(boardId: String, completionHandler:@escaping (DBBoard?) -> Void){
        //Load Boards from Realm
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "objectId = %@", boardId)
        let dbBoard = realm.objects(DBBoard.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false).first
        completionHandler(dbBoard)
    }
    
    func updateBoard(pinData: NSDictionary){
        let boardId = pinData.object(forKey: "boardId")
        if(boardId != nil){
            ref = Database.database().reference().child(boardDatabase).child((currentUser?.uid)!).child(boardId as! String)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() { return }
                //Find Board for BoardId
                let board = snapshot.value as! NSDictionary
                var boardImages = board["images"] as? String
                //Convert string of recent images to Array
                var boardImageArray = [String]()
                if(boardImages != nil){
                    boardImageArray = (boardImages?.components(separatedBy: ","))!
                }
                //Insert new Image string
                let imageString = pinData.object(forKey: "image") as! String
                boardImageArray.insert(imageString, at: 0)
                //Limit Board Images to 5
                boardImageArray = Array(boardImageArray.prefix(5))
                //Convert Array back to string
                boardImages = boardImageArray.joined(separator: ",")
                //Update Board
                self.ref.updateChildValues(["images": boardImages!, "updatedAt": ServerValue.timestamp()])
            })
        }
    }
    
    func downloadBoards(uid: String, completionHandler:@escaping ([DBBoard]?) -> Void){
        var boards = [DBBoard]()
        ref = Database.database().reference().child(boardDatabase).child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            
            for child in snapshot.children{
                //Find Pin for PinId
                let childSnapshot = child as? DataSnapshot
                let rawData = childSnapshot?.value as! NSDictionary
                let board = self.createBoard(rawData: rawData)
                boards.insert(board, at: 0)
            }
            completionHandler(boards)
        })
    }
    
    func downloadBoard(pin: DBPin?, completionHandler:@escaping (DBBoard?) -> Void){
        let boardId = pin?.boardId
        let createdBy = pin?.createdBy
        ref = Database.database().reference().child(boardDatabase).child(createdBy!).child(boardId!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            //Find Board for BoardId
            let rawData = snapshot.value as? NSDictionary
            let dbBoard = self.createBoard(rawData: rawData)
            completionHandler(dbBoard)
        })
    }
    
    func downloadBoard(boardId: String?, boardCreatorId: String?, completionHandler:@escaping (DBBoard?) -> Void){
        ref = Database.database().reference().child(boardDatabase).child(boardCreatorId!).child(boardId!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            //Find Board for BoardId
            let rawData = snapshot.value as? NSDictionary
            let dbBoard = self.createBoard(rawData: rawData)
            completionHandler(dbBoard)
        })
    }
    
    func createBoard(rawData: NSDictionary?) -> DBBoard{
        let board = DBBoard()
        board.objectId = rawData?.object(forKey: "objectId") as! String!
        board.createdAt = rawData?.object(forKey: "createdAt") as! Double
        board.updatedAt = rawData?.object(forKey: "updatedAt") as! Double
        board.name = rawData?.object(forKey: "name") as! String!
        board.images = rawData?.object(forKey: "images") as! String!
        board.createdBy = rawData?.object(forKey: "createdBy") as! String!
        return board
    }
}

extension BoardManager{
    
    func lastUpdatedAt() -> Double{
        //Return all DBBoards from Realm and return most recent updatedAt date
        let realm = try! Realm()
        let board = realm.objects(DBBoard.self).sorted(byKeyPath: "updatedAt", ascending: true).last
        if(board != nil){
            return (board?.updatedAt)!
        }
        else{
            return 0
        }
    }
}

extension BoardManager{

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
        ref = Database.database().reference(withPath: boardDatabase).child((currentUser?.uid)!)
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
        
        query.observe(.childRemoved, with: { (snapshot) -> Void in
            let rawData = snapshot.value as! NSDictionary
            if(rawData["updatedAt"] != nil){
                self.deleteInRealm(rawData: rawData)
            }
        })
    }
    
    func updateRealm(rawData: NSDictionary){
        let realm = try! Realm()
        try! realm.write {
            realm.create(DBBoard.self, value: rawData, update: true)
        }
    }
    
    func deleteInRealm(rawData: NSDictionary){
        let realm = try! Realm()
        let realmPredicate = NSPredicate(format: "objectId = %@", rawData["objectId"] as! String)
        let dbBoard = realm.objects(DBBoard.self).filter(realmPredicate).sorted(byKeyPath: "updatedAt", ascending: false)
        try! realm.write{
            realm.delete(dbBoard)
        }
    }
}
