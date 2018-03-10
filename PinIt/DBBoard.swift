//
//  DBBoard.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/19/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import RealmSwift

class DBBoard: Object{
    dynamic var objectId: String!
    dynamic var createdAt = Double()
    dynamic var updatedAt = Double()
    dynamic var name: String!
    dynamic var images: String!
    dynamic var createdBy: String!
    
    override static func primaryKey() -> String? {
        return boardPrimaryKey
    }
}
