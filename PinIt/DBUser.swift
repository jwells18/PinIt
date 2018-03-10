//
//  DBUser.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/25/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import RealmSwift

class DBUser: Object{
    dynamic var objectId: String!
    dynamic var createdAt = Double()
    dynamic var updatedAt = Double()
    dynamic var displayName: String!
    dynamic var username: String!
    dynamic var image: String!
    dynamic var about: String!
    dynamic var location: String!
    dynamic var website: String!
    dynamic var images: String!
    dynamic var followerCount = Int()
    dynamic var followingCount = Int()
    
    override static func primaryKey() -> String? {
        return userPrimaryKey
    }
}
