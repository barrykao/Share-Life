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
    let alert = UIAlertController(title: "Warning!", message: "There was some place you must be miss!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
}

func judge(controller: UIViewController){
    let alert = UIAlertController(title: "Warning!", message: "This space did not less than six or more than ten!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
}

func judgeNickName(controller: UIViewController){
    let alert = UIAlertController(title: "Warning!", message: "This space did not more than five!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
}


