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
import RSKImageCropper

protocol MemberViewControllerDelegate: class {
    func didEditPaper(note: PaperData)
}

class MemberViewController: UIViewController, UIImagePickerControllerDelegate ,UINavigationControllerDelegate ,RSKImageCropViewControllerDelegate, MessageViewControllerDelegate, EditPostViewControllerDelegate {
   
    @IBOutlet var account: UILabel!

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var imageBtn: UIButton!
    
    @IBOutlet var heartCount: UILabel!
    
    @IBOutlet var nickName: UILabel!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var sendBtn: UIButton!
    
    @IBOutlet var nicknameView: UIView!
    
    @IBOutlet var heartView: UIView!
    
    @IBOutlet var profileView: UIView!
    
    
    var messageButton: UIButton!
    var heartButton: UIButton!
    var editButton: UIButton!

    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    var memberData: [PaperData] = []
    var userData: [UserData] = []
    var refreshControl:UIRefreshControl!

    var isEdit : Bool = false
    let fullScreenSize = UIScreen.main.bounds.size
    var count: Int = 0
    var images: [UIImage] = []
    var delegate: MemberViewControllerDelegate?

    var flag: Bool = true
    var index: Int!
    var lightboxController: LightboxController = LightboxController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account.layer.borderWidth = 0.5
        account.layer.cornerRadius = 5.0
       
        nicknameView.layer.borderWidth = 0.5
        nicknameView.layer.cornerRadius = 5.0
        heartView.layer.borderWidth = 0.5
        heartView.layer.cornerRadius = 5.0
        profileView.layer.borderWidth = 0.5
        profileView.layer.cornerRadius = 5.0
        
        let paper :AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.memberData = paper.paperData
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.nickName.text = ""
        collectionView.layer.borderWidth = 0.5
        collectionView.layer.cornerRadius = 5.0
        
        let layout = collectionView.collectionViewLayout as?    UICollectionViewFlowLayout
        let width = (UIScreen.main.bounds.width - 20 * 2) / 3
        print(width)
        layout?.itemSize = CGSize(width: width, height: width)
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // reload
        refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(collectionViewReloadData), for: UIControl.Event.valueChanged)
        refreshBtn(1)
        
        messageButton = UIButton(frame:  CGRect(x: fullScreenSize.width - 60, y: fullScreenSize.height - 153, width: 50, height: 50))
        messageButton.setImage(UIImage(named: "message"), for: .normal)
        messageButton.setTitleColor(UIColor.white, for: .normal)
        
        heartButton = UIButton(frame:  CGRect(x: 10, y: fullScreenSize.height - 153, width: 50, height: 50))
        heartButton.setImage(UIImage(named: "fullHeart"), for: .normal)
        heartButton.setTitleColor(UIColor.white, for: .normal)
        
        editButton = UIButton(frame:  CGRect(x: fullScreenSize.width - 60, y: 100, width: 50, height: 50))
        editButton.setImage(UIImage(named: "file"), for: .normal)
        editButton.setTitleColor(UIColor.white, for: .normal)
        
        textView.text = "在想些什麼?"
        textView.textColor = UIColor.lightGray
        textView.font = UIFont(name: "verdana", size: 14.0)
        textView.returnKeyType = .done
        textView.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")

        if Auth.auth().currentUser != nil {
            print("登入成功")
            isEdit = false
            sendBtn.setImage(UIImage(named: "file"), for: .normal)
            textView.isUserInteractionEnabled = false

            print("顯示圖片")
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            self.account.text = account
            let fileName = "\(account).jpg"
            let photoImage = loadImage(fileName: fileName)
            self.imageBtn.setImage(photoImage, for: .normal)
            imageBtn.imageView?.layer.cornerRadius = (imageBtn.imageView?.frame.height)!/2
          
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let databaseUid = self.databaseRef.child("User").child(uid)
            databaseUid.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let uidDict = snapshot.value as? [String:Any] else {return}
                guard let nickName = uidDict["nickName"] as? String else {return}
                UserDefaults.standard.set(nickName, forKey: "nickName")
                print(nickName)
                self.nickName.text = nickName
                 guard let profile = uidDict["profile"] as? String else {return}
                if profile == "" {
                    self.textView.text = "在想些什麼?"
                }else {
                    self.textView.text = profile
                    self.textView.textColor = UIColor.black
                    self.textView.font = UIFont(name: "verdana", size: 14.0)
                }
            })
            
            collectionViewReloadData()
        }else{
            print("尚未登入")
            if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
            {
                present(signVC, animated: true, completion: nil)
                self.databaseRef.removeAllObservers()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    @objc func collectionViewReloadData() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()){
            
            self.refreshControl.endRefreshing()
            
            guard let uid = UserDefaults.standard.string(forKey: "uid") else {return}
            let databaseRefPaper = Database.database().reference().child("Paper")
            databaseRefPaper.observeSingleEvent(of: .value, with: { (snapshot) in
                if let uploadDataDic = snapshot.value as? [String:Any] {
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)
                    self.count = 0
                    self.memberData = []
                    for i in 0 ..< keyArray.count {
                        if let array = dataDic[keyArray[i]] as? [String:Any] {
                            if uid == array["uid"] as? String {

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
                                    self.count += note.heartCount
                                }else {
                                    note.heartCount = 0
                                }
                                self.heartCount.text = "\(self.count)顆"
                                self.memberData.append(note)
                                // sort Post
                                self.memberData.sort(by: { (post1, post2) -> Bool in
                                    post1.postTime! > post2.postTime!
                                })
                                
                                for j in 0 ..< note.imageName.count {
                                    // loadImageToFile
                                    let fileName = "\(note.imageName[j]).jpg"
                                    if checkFile(fileName: fileName) {
//                                        print(fileName)
                                    }else {
                                    let storageRefPhoto = self.storageRef.child(note.account!).child(fileName)
                                        
                                        storageRefPhoto.getData(maxSize: 1*1024*1024) { (data, error) in
                                            guard let imageData = data else {return}
                                            let filePath = fileDocumentsPath(fileName: fileName)
                                            do {
                                                try imageData.write(to: filePath)
                                                if j == note.imageName.count - 1 {
                                                    DispatchQueue.main.async {
                                                        self.collectionView.reloadData()
                                                    }
                                                }
                                            }catch{
                                                print("error: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.collectionView.reloadData()
                }
            })
            
        }
    }
    
    @IBAction func imageBtn(_ sender: Any) {
        
//        imagePicker1.delegate = self
        
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
        
        let imagePicker1 = RSKImageCropViewController(image: image, cropMode: .circle)
        self.imageBtn.setImage(image, for: .normal)
        imagePicker1.delegate = self
        imagePicker1.avoidEmptySpaceAroundImage = true
        imagePicker1.alwaysBounceHorizontal = true
        imagePicker1.alwaysBounceVertical = true
        
        picker.pushViewController(imagePicker1, animated: true)
        
    }
    
    @objc func messageVC() {
        print("messageVC")
        let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "messageVC") as! UINavigationController
        let messageVC = navigationVC.topViewController as! MessageViewController
        messageVC.delegate = self
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
    
    @objc func editVC() {
        
        print("editVC")

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
                        editPostVC.currentData = current
                        editPostVC.images = self.images
                        editPostVC.delegate = self
                        self.present(navigationVC, animated: true, completion: nil)
                        
                    }
                    
                }
                if action.title == "刪除貼文" {
                    print("刪除貼文")
                    // ....
                    let controller = UIAlertController(title: "刪除貼文", message: "請問是否確認刪除貼文", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                        print("Yes")
                        let currentData = self.memberData[self.index]
                        guard let account = UserDefaults.standard.string(forKey: "account") else {return}
                        let storageRefAccount = self.storageRef.child(account)
                        let databaseRefPaper = self.databaseRef.child("Paper")
                        databaseRefPaper.child(currentData.paperName!).removeValue()
                        for i in 0 ..< currentData.imageName.count {
                            let imageName = "\(currentData.imageName[i]).jpg"
                            storageRefAccount.child(imageName).delete(completion: { (error) in
                                if let error = error {
                                    print("error: \(error)")
                                }
                                if checkFile(fileName: imageName) {
                                    let url = fileDocumentsPath(fileName: imageName)
                                    do{
                                        try FileManager.default.removeItem(at: url)
                                        if i == currentData.imageName.count - 1 {
                                            DispatchQueue.main.async {
                                                self.collectionView.reloadData()
                                            }
                                        }
                                    }catch{
                                        print("error: \(error)")
                                    }
                                }
                            })
                            
                        }
                        self.memberData.remove(at: self.index)
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
    
    @IBAction func signOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "登出成功", message: "希望您再次使用", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
       
            if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
            {
                self.present(signVC, animated: true, completion: nil)
            }
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
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        let image = croppedImage
        guard let account = UserDefaults.standard.string(forKey: "account")else {return}
        let fileName = "\(account).jpg"
        guard let thumbImage = thumbmail(image: image) else {return}
        guard let photoImage = circleImage(image: thumbImage , fileName: fileName) else {return}
        self.imageBtn.setImage(photoImage, for: .normal)
      
        // upload to firebase
        
        let now:Date = Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormat.string(from: now)
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let nickName = UserDefaults.standard.string(forKey: "nickName") else {return}
        guard let imageData = photoImage.jpegData(compressionQuality: 1) else {return}
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
                let databasePhoto = self.databaseRef.child("User").child(uid)
                let postMessage: [String : Any] = ["account" : account,
                                                    "date" : dateString,
                                                    "uid" : uid,
                                                    "nickName" : nickName,
                                                    "photo" : uploadImageUrl,
                                                    "postTime": [".sv":"timestamp"]
                                                  ]
                
                databasePhoto.updateChildValues(postMessage, withCompletionBlock: { (error, dataRef) in
                    if error != nil{
                        print("Database Error: \(error!.localizedDescription)")
                    }else{
                        print("圖片已儲存")
                    }
                })
                
            })
        }
        
        
        controller.dismiss(animated: true)
        
        
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        
        
        isEdit = !isEdit
        if isEdit {
            sendBtn.setImage(UIImage(named: "save"), for: .normal)
            textView.isUserInteractionEnabled = true
        }else {
            let alert = UIAlertController(title: "送出成功", message: "已成功修改個人簡介", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                
                guard let uid = UserDefaults.standard.string(forKey: "uid") else {return}
                let databaseUser = self.databaseRef.child("User").child(uid)
                let profile: [String:Any] = ["profile" : self.textView.text!]
                databaseUser.updateChildValues(profile) { (error, data) in
                    if let error = error {
                        print("error: \(error)")
                    }else {
                        print("個人簡介上傳成功")
                        self.sendBtn.setImage(UIImage(named: "file"), for: .normal)
                        self.textView.isUserInteractionEnabled = false
                    }
                }
                
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    func didUpdateMessage() {
        refreshBtn(1)
    }
    func didUpdatePaper() {
        refreshBtn(1)
    }
}


extension MemberViewController : UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GLCell", for: indexPath) as! PhotoCollectionViewCell
        print(indexPath.row)
        
        let note = self.memberData[indexPath.item]
        if let fileName = note.imageName.first {
                cell.photoView.tag = indexPath.item
                cell.photoView.image = loadImage(fileName: "\(fileName).jpg")
                cell.photoView.layer.cornerRadius = 20
                cell.photoView.layer.shadowOpacity = 0.5
                print(fileName)
            if note.imageName.count > 1 {
                cell.picturesView.image = UIImage(named: "pictures")
            }else {
                cell.picturesView.image = nil
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("\(indexPath.section),\(indexPath.item)")
        self.images = []
        guard self.memberData[indexPath.item].imageName.count > 0 else { return }
        let note = self.memberData[indexPath.item]
        let fileName = note.imageName
    
        var light: [LightboxImage] = []
        for i in 0 ..< note.imageName.count {
            self.images.append(loadImage(fileName: "\(fileName[i]).jpg")!)
            light.append(LightboxImage(image: self.images[i], text: note.message!))
        }
     
        lightboxController = LightboxController(images: light, startIndex: 0)
        lightboxController.dynamicBackground = true
        lightboxController.imageTouchDelegate = self
      
        self.present(lightboxController, animated: true, completion: nil)
        
        lightboxController.view.addSubview(messageButton)
        lightboxController.view.addSubview(heartButton)
        lightboxController.view.addSubview(editButton)
        flag = true
        UIView.animate(withDuration: 0.25, animations: {
            self.messageButton.alpha = self.flag ? 1.0 : 0.0
            self.heartButton.alpha = self.flag ? 1.0 : 0.0
            self.editButton.alpha = self.flag ? 1.0 : 0.0
        })
        messageButton.addTarget(self, action: #selector(messageVC), for: .touchUpInside)
        heartButton.addTarget(self, action: #selector(heartVC), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editVC), for: .touchUpInside)
 
        self.index = indexPath.item
        
    }

}
extension MemberViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "在想些什麼?" {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 14.0)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = "在想些什麼?"
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "verdana", size: 14.0)
        }
    }
    
}


extension MemberViewController: LightboxControllerTouchDelegate {
    
    func lightboxController(_ controller: LightboxController, didTouch image: LightboxImage, at index: Int) {
        print("didTouch")
        
        flag = !flag
        UIView.animate(withDuration: 0.25, animations: {
            self.messageButton.alpha = self.flag ? 1.0 : 0.0
            self.heartButton.alpha = self.flag ? 1.0 : 0.0
            self.editButton.alpha = self.flag ? 1.0 : 0.0
        })
        
        
        
    }
    
  
}
 
