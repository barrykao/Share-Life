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

func image() -> UIImage? {
    
        let photoName = UserDefaults.standard.string(forKey: "account")
    print(photoName)
     if let fileName = photoName {
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent(fileName)
        //如果取得到指定位置的Data，才產生UIImage物件
        
        if let imageData = try? Data(contentsOf: fileURL){
                return UIImage(data: imageData)
        }
    
    }
    return nil
}


func thumbnailImage() -> UIImage? {
    
    if let image = image() {
        
        let thumbnailSize = CGSize(width:50, height: 50); //設定縮圖大小
        let scale = UIScreen.main.scale //找出目前螢幕的scale，視網膜技術為2.0
        
        //產生畫布，第一個參數指定大小,第二個參數true:不透明（黑色底）,false表示透明背景,scale為螢幕scale
        UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
        
        //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
        //最小值MIN會變成UIViewContentModeScaleAspectFit
        let widthRatio = thumbnailSize.width / image.size.width;
        let heightRadio = thumbnailSize.height / image.size.height;
        
        let ratio = max(widthRatio,heightRadio);
        
        let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
        //如果要切圓形請加下面兩行
        //            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0,y: 0,width: thumbnailSize.width,height: thumbnailSize.height))
        //            circlePath.addClip()
        
        image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,
                             width: imageSize.width,height: imageSize.height))
        //取得畫布上的縮圖
        let smallImage = UIGraphicsGetImageFromCurrentImageContext();
        //關掉畫布
        UIGraphicsEndImageContext();
        return smallImage
    }else{
        return nil;
    }
}

/*
func judge(controller: UIViewController){
    let alert = UIAlertController(title: "警告!", message: "帳號或密碼不足6位數!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
}
*/

