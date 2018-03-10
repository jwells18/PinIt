//
//  Pin.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/23/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import UIKit

class Pin: NSObject{
    var objectId: String!
    var createdAt = Double()
    var updatedAt = Double()
    var image = UIImage()
    var imageWidth = Float()
    var imageHeight = Float()
    var caption: String!
    var createdBy: String!
    var website: String!
    var pinnedBy: String!
    var boardId: String!
}
