//
//  Database.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/20.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import CoreData



class DatabaseData : NSObject,NSCoding {

    func encode(with aCoder: NSCoder) {
        //把物件存到檔案
        //aCoder當作是Dictionary，會自動把存在裡面的值寫到檔案
        aCoder.encode(self.paperName, forKey: "paperName")
    }

    required init?(coder aDecoder: NSCoder) {
        //檔案轉成物件
        self.paperName = aDecoder.decodeObject(forKey: "paperName") as? String
        
    }
    var paperName : String?
}
