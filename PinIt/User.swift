//
//  User.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/25/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation

class User: NSObject{
    var objectId: String!
    var createdAt = Double()
    var updatedAt = Double()
    var displayName: String!
    var username: String!
    var image: String!
    var about: String!
    var location: String!
    var website: String!
    var followerCount: Int!
    var followingCount: Int!
}
