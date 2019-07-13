//
//  Database.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/20.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class DatabaseData {
    
    var paperName : String?
    var account : String?
    var date : String?
    var message : String?
    var url : String?
    var uid : String?
    var postTime : Double?
    var commentCount: Int = 0
    var heartCount: Int = 0
    var heartUid: [String] = []
    var imageName : [String] = []
    var nickName: String?
}

class CommentData {
    
    var commentName: String?
    var account : String?
    var postTime : Double?
    var comment: String?
    var uid : String?
    var commentUUID : String
    var nickName: String?

    init() {
        self.commentUUID = UUID().uuidString
    }
}

class HeartData {
    
    var heartName: String?
    var account : String?
    var postTime : Double?
    var uid : String?
    var heartUUID : String
    var nickName: String?

    init() {
        self.heartUUID = UUID().uuidString
    }
    
    
}
