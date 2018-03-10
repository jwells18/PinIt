//
//  RealmManager.swift
//  WalkieTalkie
//
//  Created by Justin Wells on 2/24/18.
//  Copyright © 2018 SynergyLabs. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager: NSObject{
    
    func setDefaultRealmForUser(uid: String) {
        var config = Realm.Configuration()
        
        //Realm default configuration for each user
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(uid).realm")
        Realm.Configuration.defaultConfiguration = config
    }
}
