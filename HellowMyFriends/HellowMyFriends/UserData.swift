//
//  UserData.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/5/29.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import UIKit

class UserData : Codable {
   
    var userAccount : String?
    var userPassword : String?
    var userNickname : String?
    var userBirthday : String?
    

    init(){
        
    }
    
}

class ImageData {
    
    var image : UIImage?
    
}
