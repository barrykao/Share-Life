//
//  Database.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/20.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import CoreData
/*
class DatabaseData : NSObject,NSCoding {

    func encode(with aCoder: NSCoder) {
        //把物件存到檔案
        //aCoder當作是Dictionary，會自動把存在裡面的值寫到檔案
        aCoder.encode(self.paperName, forKey: "paperName")
        aCoder.encode(self.account, forKey: "account")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.message, forKey: "message")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.uid, forKey: "uid")

        
    }

    required init?(coder aDecoder: NSCoder) {
        //檔案轉成物件
        self.paperName = aDecoder.decodeObject(forKey: "paperName") as! String
        self.account = aDecoder.decodeObject(forKey: "account") as? String
        self.date = aDecoder.decodeObject(forKey: "date") as? String
        self.message = aDecoder.decodeObject(forKey: "message") as? String
        self.url = aDecoder.decodeObject(forKey: "url") as? String
        self.uid = aDecoder.decodeObject(forKey: "uid") as? String


        super.init()
    }
    override init() {
        self.paperName = UUID().uuidString
    }
    var paperName : String
    
    var account : String?
    var date : String?
    var message : String?
    var url : String?
    var uid : String?
    
}
*/



class DatabaseData : Equatable {
    static func == (lhs: DatabaseData, rhs: DatabaseData) -> Bool {
        return lhs === rhs
    }
    
    var paperName : String
    
    var account : String?
    var date : String?
    var message : String?
    var url : String?
    var uid : String?
    
    
    
    init() {
        self.paperName = UUID().uuidString
    }
    
    
}
 
/*
class DatabaseData : NSManagedObject {

    @NSManaged var account : String?
    @NSManaged var date : String?
    @NSManaged var message : String?
    @NSManaged var url : String?
    @NSManaged var uid : String?
    @NSManaged var paperName : String
    
    override func awakeFromInsert() {
        self.paperName = UUID().uuidString
    }

}
*/
