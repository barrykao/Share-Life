//
//  MemberViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/8.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Lightbox


class MemberViewController: UIViewController, UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    @IBOutlet var account: UILabel!

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var imageBtn: UIButton!
    
    @IBOutlet var heartCount: UILabel!
    
    var messageButton: UIButton!
    var heartButton: UIButton!
    var editButton: UIButton!

    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    var memberData: [DatabaseData] = []
    var refreshControl:UIRefreshControl!
    var isNewPhoto : Bool = false
    let fullScreenSize = UIScreen.main.bounds.size
    var count: Int = 0
    var images: [UIImage] = []
    var message: [String] = []
    var lightboxImages: [[LightboxImage]] = [[]]
    var flag: Bool = true
    var index: Int!
    var lightboxController: LightboxController = LightboxController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // reload
        refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(collectionViewReloadData), for: UIControl.Event.valueChanged)
        refreshBtn(1)
        
        messageButton = UIButton(frame:  CGRect(x: 350, y: 580, width: 50, height: 50))

        messageButton.setImage(UIImage(named: "message"), for: .normal)
        messageButton.setTitleColor(UIColor.white, for: .normal)
        
        heartButton = UIButton(frame:  CGRect(x: 10, y: 580, width: 100, height: 50))

        heartButton.setImage(UIImage(named: "chocolate"), for: .normal)

        heartButton.setTitleColor(UIColor.white, for: .normal)
        
        editButton = UIButton(frame:  CGRect(x: 350, y: 100, width: 50, height: 50))

        editButton.setImage(UIImage(named: "file"), for: .normal)

        editButton.setTitleColor(UIColor.white, for: .normal)
        
        guard let account = UserDefaults.standard.string(forKey: "account") else {return}
        self.account.text = account
        print("顯示圖片")
        let fileName = "\(account).jpg"
        if checkFile(fileName: fileName) {
            print("照片存在")
            let photoImage = loadImage(fileName: fileName)
            self.imageBtn.setImage(photoImage, for: .normal)
            
        }else {
            let uid = Auth.auth().currentUser!.uid
            databaseRef = databaseRef.child("User").child(uid).child("photo")
            loadImageToFile(fileName: fileName, database: databaseRef)
        }
        
        // load photoImageViewToFile
        databaseRef = Database.database().reference()
        databaseRef.child("User").observe(.value) { (snapshot) in
            
            guard let uploadDataDic = snapshot.value as? [String:Any] else {return}
            let dataDic = uploadDataDic
            let keyArray = Array(dataDic.keys)
            for i in 0 ..< keyArray.count {
                let array = dataDic[keyArray[i]] as! [String:Any]
                let databasePhoto = self.databaseRef.child("User").child(keyArray[i]).child("photo")
                guard let photoName = array["account"] as? String else {return}
                loadImageToFile(fileName: "\(photoName).jpg", database: databasePhoto)
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            print("登入成功")
        }else{
            print("尚未登入")
            if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
            {
                present(signVC, animated: true, completion: nil)
            }
        }
    }

    @IBAction func refreshBtn(_ sender: Any) {
        refreshControl.beginRefreshing()
        // 使用 UIView.animate 彈性效果，並且更改 TableView 的 ContentOffset 使其位移
        // 動畫結束之後使用 loadData()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.collectionView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.height)
            
        }) { (finish) in
            self.collectionViewReloadData()
        }
    }

    @IBAction func signOut(_ sender: Any) {
        
            let alert = UIAlertController(title: "登出成功", message: "謝謝", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                
                if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
                {
                    self.present(signVC, animated: true, completion: nil)
                }
//                self.photo.image = UIImage(named: "member.png")
                self.imageBtn.imageView?.image = UIImage(named: "member.png")

            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: {
                        
                do {
                    try Auth.auth().signOut()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            })
    }
    
    @objc func collectionViewReloadData() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
            
            self.refreshControl.endRefreshing()
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            let fileName = "\(account).jpg"
            let photoImage = loadImage(fileName: fileName)
            self.imageBtn.setImage(photoImage, for: .normal)
            
            let databaseRefPaper = Database.database().reference().child("Paper")
            databaseRefPaper.observe(.value, with: { (snapshot) in
                if let uploadDataDic = snapshot.value as? [String:Any] {
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)
                    
                    self.count = 0
                    self.memberData = []
                    self.images = []
                    self.message = []
                    self.lightboxImages = [[]]
                    
                    

                    
                    for i in 0 ..< keyArray.count {
                        
                        if let array = dataDic[keyArray[i]] as? [String:Any] {
                            let uid = Auth.auth().currentUser?.uid
                            if uid == array["uid"] as? String {
                                
                                let note = DatabaseData()
                                note.paperName = keyArray[i]
                                note.account = array["account"] as? String
                                note.message = array["message"] as? String
                                note.date = array["date"] as? String
                                note.imageName = array["photo"] as! [String]
                                note.imageURL = array["photourl"] as! [String]
                                note.uid = array["uid"] as? String
                                note.postTime = array["postTime"] as? Double
                                
                                if array["comment"] as? String == "commentData" {
                                    //                            print("0則留言")
                                    note.commentCount = 0
                                }else {
                                    guard let comment = array["comment"] as? [String:Any] else {return}
                                    note.commentCount = comment.count
                                }
                                if array["heart"] as? String == "heartData" {
                                    //                            print("0顆愛心")
                                    note.heartCount = 0
                                }else {
                                    guard let heart = array["heart"] as? [String:Any] else {return}
                                    note.heartUid = Array(heart.keys)
                                    note.heartCount = heart.count
                                    self.count += note.heartCount
                                }
                                self.heartCount.text = "\(self.count)塊"
                                
                                
                                self.memberData.append(note)
                                // sort Post
                                self.memberData.sort(by: { (post1, post2) -> Bool in
                                    post1.postTime! > post2.postTime!
                                })
                                
                                for j in 0 ..< note.imageName.count {
                                    // PhotoView
                                    let fileName = "\(note.imageName[j]).jpg"
                                    if checkFile(fileName: fileName) {
                                    }else{
                                        let databaseImageView = databaseRefPaper.child(keyArray[i]).child("photourl").child("\(i)")
                                        loadImageToFile(fileName: fileName, database: databaseImageView)
                                    }
                                    
                                    self.images.append(loadImage(fileName: "\(note.imageName[j]).jpg")!)
                                    
                                    print("\(note.imageName[j]).jpg")
                                    self.message.append(note.message!)
                                    let lightbox = LightboxImage(image: self.images[j], text: self.message[j])
                                    self.lightboxImages[i].append(lightbox)
                                    
                                }
                                self.images = []
                                self.message = []
                            }
                        }
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            })
            
        }
    }
    
    @IBAction func imageBtn(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let controller = UIAlertController(title: "變更圖片", message: "請選擇要上傳的照片或啟用相機", preferredStyle: .actionSheet)
        let names = ["照片圖庫", "相機"]
        for name in names {
            let action = UIAlertAction(title: name, style: .default) { (action) in
                if action.title == "照片圖庫" {
                    imagePicker.sourceType = .savedPhotosAlbum
                }
                if action.title == "相機" {
                    imagePicker.sourceType = .camera
                }
                self.present(imagePicker, animated: true, completion: nil)
            }
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        guard let account = UserDefaults.standard.string(forKey: "account")else {return}
        let fileName = "\(account).jpg"
        guard let thumbImage = thumbmail(image: image) else {return}
        let photoImage = circleImage(image: thumbImage , fileName: fileName)
        self.imageBtn.setImage(photoImage, for: .normal)
        
        // upload to firebase
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.databaseRef = self.databaseRef.child("User").child(uid)
        let now:Date = Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormat.string(from: now)
        if let image = photoImage ,
            let imageData = image.jpegData(compressionQuality: 1) ,
            let account = UserDefaults.standard.string(forKey: "account") {
            storageRef = Storage.storage().reference().child(account).child(fileName)
            let metadata = StorageMetadata()
            storageRef.putData(imageData, metadata: metadata) { (data, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                self.storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    guard let uploadImageUrl = url?.absoluteString else {return}
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    
                    let postMessage: [String : Any] = ["account" : account,
                                                       "date" : dateString,
                                                       "uid" : uid,
                                                       "photo" : uploadImageUrl,
                                                       "postTime": [".sv":"timestamp"],
                                                      ]
                    
                    self.databaseRef.updateChildValues(postMessage, withCompletionBlock: { (error, dataRef) in
                        if error != nil{
                            print("Database Error: \(error!.localizedDescription)")
                        }else{
                            print("圖片已儲存")
                        }
                    })
                    
                })
            }
//            picker.dismiss(animated: true)
        }
        
        picker.dismiss(animated: true)
    }
    
    
    
    @objc func messageVC () {
        print("messageVC")
        let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "messageVC") as! UINavigationController
        let messageVC = navigationVC.topViewController as! MessageViewController
        let note = self.memberData[self.index]
        messageVC.messageData = note
        lightboxController.present(navigationVC, animated: true)
    }
    
    
    @objc func heartVC() {
        print("heartVC")
        
        let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "heartVC") as! UINavigationController
        let messageVC = navigationVC.topViewController as! HeartViewController
        let note = self.memberData[self.index]
        messageVC.messageData = note
        lightboxController.present(navigationVC, animated: true, completion: nil)
    }
    /*
    @objc func editVC() {
        
        
        let controller = UIAlertController(title: "修改貼文", message: "請選擇操作功能", preferredStyle: .actionSheet)
        let names = ["編輯貼文", "刪除貼文"]
        for name in names {
            let action = UIAlertAction(title: name, style: .default) { (action) in
                if action.title == "編輯貼文" {
                    if let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "EditPostVC") as? UINavigationController
                    {
                        print("編輯貼文")
                        self.dismiss(animated: true)
                        let current = self.memberData[self.index]
                        let editPostVC = navigationVC.topViewController as! EditPostViewController
                        editPostVC.editData = current
                        editPostVC.editImage = image(fileName: current.imageName!)
                        self.present(navigationVC, animated: true, completion: nil)
                    }
                    
                }
                if action.title == "刪除貼文" {
                    print("刪除貼文")
                    // ....
                    let controller = UIAlertController(title: "刪除貼文", message: "請問是否確認刪除貼文", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                        print("Yes")
                        let current = self.memberData[self.index]
                        guard let account = UserDefaults.standard.string(forKey: "account") else {return}
                        let storageRefAccount = self.storageRef.child("\(account).jpg")
                        storageRefAccount.child(current.imageName!).delete(completion: nil)
                        
                        let databaseRefPaper = self.databaseRef.child("Paper")
                        databaseRefPaper.child(current.paperName!).removeValue(completionBlock: { (error, data) in
                            
                            if checkFile(fileName: current.imageName!) {
                                let url = fileDocumentsPath(fileName: current.imageName!)
                                do{
                                    try FileManager.default.removeItem(at: url)
                                }catch{
                                    print("error: \(error)")
                                }
                            }
                        })
                        self.dismiss(animated: true)
                    }
                    controller.addAction(okAction)
                    let cancelAction = UIAlertAction(title: "No", style: .destructive , handler: nil)
                    controller.addAction(cancelAction)
                    self.lightboxController.present(controller, animated: true, completion: nil)
                }
            }
            controller.addAction(action)
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        lightboxController.present(controller, animated: true, completion: nil)
        
    }
    */
    
    
}


extension MemberViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GLCell", for: indexPath) as! PhotoCollectionViewCell
        print(indexPath.row)
        
        let note = self.memberData[indexPath.item]
        let fileName = note.imageName[indexPath.item]
            cell.photoView.tag = indexPath.item
            cell.photoView.image = loadImage(fileName: "\(fileName).jpg")
            cell.photoView.layer.cornerRadius = 20
            cell.photoView.layer.shadowOpacity = 0.5
            print(fileName)
        if note.imageName.count > 1 {
            cell.label.text = "\(note.imageName.count)"
        }else {
            cell.label.text = nil
        }
        return cell
    }

}

extension MemberViewController : UICollectionViewDelegate {
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("\(indexPath.section),\(indexPath.item)")
        
        guard self.memberData[indexPath.item].imageName.count > 0 else { return }
        
        print(self.lightboxImages)
        let lightbox = self.lightboxImages[indexPath.item]
        lightboxController = LightboxController(images: lightbox, startIndex: 0)
        
        lightboxController.dynamicBackground = true
        lightboxController.imageTouchDelegate = self
        lightboxController.pageDelegate = self
        
        self.present(lightboxController, animated: true, completion: nil)
        lightboxController.view.addSubview(messageButton)
        lightboxController.view.addSubview(heartButton)
        lightboxController.view.addSubview(editButton)
        
        
        messageButton.addTarget(self, action: #selector(messageVC), for: .touchUpInside)
        heartButton.addTarget(self, action: #selector(heartVC), for: .touchUpInside)
//        editButton.addTarget(self, action: #selector(editVC), for: .touchUpInside)
        
        self.index = indexPath.item
        
    }
}

extension MemberViewController: LightboxControllerTouchDelegate, LightboxControllerPageDelegate{
    
    
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        print("didMoveToPage")
        
        print(page)
    }
    
    func lightboxController(_ controller: LightboxController, didTouch image: LightboxImage, at index: Int) {
        print("didTouch")
        
        flag = !flag
        if flag {
            messageButton.isHidden = false
            heartButton.isHidden = false
            editButton.isHidden = false
        }else {
            messageButton.isHidden = true
            heartButton.isHidden = true
            editButton.isHidden = true
        }
    }
    
    
    
}
