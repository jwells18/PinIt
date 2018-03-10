//
//  DBPin.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/24/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import RealmSwift

class DBPin: Object{
    dynamic var objectId: String!
    dynamic var createdAt = Double()
    dynamic var updatedAt = Double()
    dynamic var image: String!
    dynamic var imageWidth = Float()
    dynamic var imageHeight = Float()
    dynamic var caption: String!
    dynamic var website: String!
    dynamic var createdBy: String!
    dynamic var pinnedBy: String!
    dynamic var boardId: String!
    
    override static func primaryKey() -> String? {
        return pinPrimaryKey
    }
}
