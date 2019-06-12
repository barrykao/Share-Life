//
//  function.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/5/3.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import UIKit


func isEmpty(controller: UIViewController){
    let alert = UIAlertController(title: "警告", message: "請輸入E-mail及密碼!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
    
}
/*
func judge(controller: UIViewController){
    let alert = UIAlertController(title: "警告!", message: "帳號或密碼不足6位數!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
}
*/

