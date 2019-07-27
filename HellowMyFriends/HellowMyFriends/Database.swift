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


class PaperData: Equatable {
static func == (lhs: PaperData, rhs: PaperData) -> Bool {
    return lhs === rhs
}
    
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
    var nickName : String?
    var paperNameArray: [String] = []
    var commentNameArray: [String] = []
//    var blockUser: [String] = []
//    var blockPaper: [String] = []
}

class UserData {
    var account : String?
    var date : String?
    var nickName : String?
    var profile: String?
    var uid: String?
    var photo: String?
    var postTime : Double?

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
