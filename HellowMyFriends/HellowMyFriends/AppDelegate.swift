//
//  AppDelegate.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/4/23.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FirebaseAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!
    var paperData : [PaperData] = []
    var userData: [UserData] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = 1
       
        IQKeyboardManager.shared.enable = true
        print("home= \(NSHomeDirectory())")
        
        let databaseRefPaper = self.databaseRef.child("Paper")
        databaseRefPaper.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            guard let uploadDataDic = snapshot.value as? [String:Any] else { return}
                let dataDic = uploadDataDic
                let keyArray = Array(dataDic.keys)
                self?.paperData = []
                for i in 0 ..< keyArray.count {
                    let array = dataDic[keyArray[i]] as! [String:Any]
                    let note = PaperData()
                    note.paperName = keyArray[i]
                    note.account = array["account"] as? String
                    note.message = array["message"] as? String
                    note.date = array["date"] as? String
                    note.imageName = array["photo"] as! [String]
                    note.uid = array["uid"] as? String
                    note.postTime = array["postTime"] as? Double
                    note.nickName = array["nickName"] as? String
                    if let comment = array["comment"] as? [String:Any] {
                        note.commentCount = comment.count
                    }else {
                        note.commentCount = 0
                    }
                    if let heart = array["heart"] as? [String:Any] {
                        note.heartUid = Array(heart.keys)
                        note.heartCount = heart.count
                    }else {
                        note.heartCount = 0
                    }
                    self?.paperData.append(note)
                    self?.paperData.sort(by: { (post1, post2) -> Bool in
                        post1.postTime! > post2.postTime!
                    })
                    for j in 0 ..< note.imageName.count {
                        // loadImageToFile
                        let fileName = "\(note.imageName[j]).jpg"
                        guard let storageRefPhoto = self?.storageRef.child(note.account!).child(fileName) else {return}
                        
                        storageRefPhoto.getData(maxSize: 1*1024*1024) { (data, error) in
                            guard let imageData = data else {return}
                            let filePath = fileDocumentsPath(fileName: fileName)
                            do {
                                    try imageData.write(to: filePath)
                                print("下載Paper成功")
                            }catch{
                                print("error: \(error)")
                            }
                        }
                    }
                }
        })
        
        let databaseUser = self.databaseRef.child("User")
        databaseUser.observeSingleEvent(of: .value) { (snapshot) in
            guard let uidDict = snapshot.value as? [String:Any] else {return}
            let dataDic = uidDict
            let keyArray = Array(dataDic.keys)
            self.userData = []
            for i in 0 ..< keyArray.count {
                let array = dataDic[keyArray[i]] as! [String:Any]
                let note = UserData()
                note.account = array["account"] as? String
                self.userData.append(note)
                // loadImageToFile
                guard let account = note.account else {return}
                let fileName = "\(account).jpg"
                let storageRefPhoto = self.storageRef.child(account).child(fileName)
                storageRefPhoto.getData(maxSize: 1*1024*1024) { (data, error) in
                    guard let imageData = data else {return}
                    let filePath = fileDocumentsPath(fileName: fileName)
                    do {
                        try imageData.write(to: filePath)
                        print("下載User成功")
                    }catch{
                        print("error: \(error)")
                    }
                }
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

