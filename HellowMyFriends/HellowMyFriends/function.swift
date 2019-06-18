//
//  function.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/5/3.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import SDWebImage


func isEmpty(controller: UIViewController){
    let alert = UIAlertController(title: "警告", message: "請輸入E-mail及密碼!", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    controller.present(alert, animated: true, completion: nil)
    
}

//MARK: func - save thumbmailImage
func thumbmailImage(image :UIImage) -> UIImage? {
    
    //設定縮圖大小
    let thumbnailSize = CGSize(width: 450 ,height: 450)
    //找出目前螢幕的scale
    let scale = UIScreen.main.scale
    //產生畫布
    UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
    //計算長寬要縮圖比例
    let width = thumbnailSize.width / image.size.width
    let height = thumbnailSize.height / image.size.height
    let ratio = max(width,height)
    let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio)
    //在畫圖行前 切圓形
            let circle = UIBezierPath(ovalIn: CGRect(x: 0,y: 0,width: thumbnailSize.width,height: thumbnailSize.height))
            circle.addClip()
    image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,width: imageSize.width,height: imageSize.height))
    //取得畫布上的圖
    let smallImage = UIGraphicsGetImageFromCurrentImageContext()
    //關掉畫布
    UIGraphicsEndImageContext()
    
    let userEmail = UserDefaults.standard
    //read userdefault is login or registered?
    let emailHead = userEmail.string(forKey: "account")
    let fileName = "\(emailHead!).jpg"
    
    let filePath = fileDocumentsPath(fileName: fileName)
    
    //write file
        if let imageData = smallImage?.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
            do{
                try imageData.write(to: filePath, options: [.atomicWrite])
            }catch {
                print("uer photo fiel save is eror : \(error)")
            }
        }
    
    return smallImage
}
//MARK: func - fileURL
func fileDocumentsPath(fileName: String) -> URL {
    
    let homeURL = URL(fileURLWithPath: NSHomeDirectory())
    let documents = homeURL.appendingPathComponent("Documents")
    let fileURL = documents.appendingPathComponent(fileName)
    return fileURL
}

//MARK: func - checkfilePhoto
func image(fileName:String?) -> UIImage? {
    
    if let fileName = fileName {
        let fileURL = fileDocumentsPath(fileName: fileName)
        //如果取得到指定位置的Data，才產生UIImage物件
        if let imageData = try? Data(contentsOf: fileURL){
            if let image = UIImage(data: imageData){
                return thumbmailImage(image: image)
            }
        }
    }
    return UIImage(named: "member.png")
}


func checkFile (fileName : String) -> Bool {
    let filePath = NSHomeDirectory()+"/Documents/"+fileName
    let exist = FileManager.default.fileExists(atPath: filePath)
    return exist
}
/*
func checkImage(fileName: String) -> UIImage? {
    
    if checkFile(fileName: fileName) {
        return image(fileName: fileName)
    }
    
    if let dataDecoded = Data(base64Encoded: fileName, options: .ignoreUnknownCharacters) ,
        let image = UIImage(data: dataDecoded){
            return thumbmailImage(image: image)
        }
    return UIImage(named: "member.png")
}
*/
var storageRef : StorageReference!


func checkImage(fileName: String) -> UIImage? {
    
    if checkFile(fileName: fileName) {
        return image(fileName: fileName)
    }
    
    storageRef = Storage.storage().reference()
    storageRef.child("UserPhoto").child(fileName).downloadURL { (url, error) in
        
        guard let url = url else { return }
        
        
        
    }
    return UIImage(named: "member.png")
}


