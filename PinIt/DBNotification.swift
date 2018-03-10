//
//  DBNotification.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/27/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import RealmSwift

class DBNotification: Object{
    dynamic var objectId: String!
    dynamic var createdAt = Double()
    dynamic var updatedAt = Double()
    dynamic var type: String!
    dynamic var message: String!
    dynamic var profilePicture: String!
    dynamic var images: String!
    dynamic var boardId: String!
    dynamic var createdBy: String!
    dynamic var recipientId: String!
    dynamic var boardCreatorId: String!
    
    override static func primaryKey() -> String? {
        return notificationPrimaryKey
    }
}
