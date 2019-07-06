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


class MemberViewController: UIViewController, UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    
    @IBOutlet var account: UILabel!

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var imageBtn: UIButton!
    
    @IBOutlet var heartCount: UILabel!
    
    
    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    var memberData: [DatabaseData] = []
    var refreshControl:UIRefreshControl!
    var isNewPhoto : Bool = false
    let fullScreenSize = UIScreen.main.bounds.size
    var count: Int = 0
    
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
    
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
        if Auth.auth().currentUser != nil {
            print("登入成功")
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            self.account.text = account
            print("顯示圖片")
            
            let fileName = "\(account).jpg"
            if checkFile(fileName: fileName) {
               print("照片存在")
                let photoImage = image(fileName: fileName)
                DispatchQueue.main.async {
                    self.imageBtn.setImage(photoImage, for: .normal)
                }
            }else {
                let uid = Auth.auth().currentUser!.uid
                databaseRef = databaseRef.child("User").child(uid).child("photo")
                loadImageToFile(fileName: fileName, database: databaseRef)
                let photoImage = image(fileName: fileName)
                DispatchQueue.main.async {
                    self.imageBtn.setImage(photoImage, for: .normal)
                }
            }
//            let photoImage = image(fileName: fileName)
//            DispatchQueue.main.async {
//                self.imageBtn.setImage(photoImage, for: .normal)
//            }
            // collectionView
//            reloadAnmiation()

        }else{
            print("尚未登入")
            if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
            {
                present(signVC, animated: true, completion: nil)
            }
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

            let databaseRefPaper = Database.database().reference().child("Paper")
            databaseRefPaper.observe(.value, with: { (snapshot) in
                if let uploadDataDic = snapshot.value as? [String:Any] {
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)
                    
                    self.memberData = []
                    for i in 0 ..< keyArray.count {
                        if let array = dataDic[keyArray[i]] as? [String:Any] {
                            let uid = Auth.auth().currentUser?.uid
                            if uid == array["uid"] as? String {
                                
                                let note = DatabaseData()
                                note.imageName = "\(keyArray[i]).jpg"
                                note.paperName = keyArray[i]
                                note.account = array["account"] as? String
                                note.message = array["message"] as? String
                                note.date = array["date"] as? String
                                note.url = array["photo"] as? String
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
                                    print(self.count)
                                }
                                self.heartCount.text = "\(self.count)塊"
                                self.memberData.append(note)
                                // sort Post
                                self.memberData.sort(by: { (post1, post2) -> Bool in
                                    post1.postTime! > post2.postTime!
                                })
                                // PhotoView
                                guard let fileName = note.imageName else {return}
                                if checkFile(fileName: fileName) {
                                    continue
                                }else{
                                    let databaseImageView = databaseRefPaper.child(keyArray[i]).child("photo")
                                    loadImageToFile(fileName: fileName, database: databaseImageView)
                                }
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
        
        DispatchQueue.main.async {
            self.imageBtn.setImage(photoImage, for: .normal)
        }
        self.imageBtn.setImage(photoImage, for: .normal)

        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.databaseRef = self.databaseRef.child("User").child(uid)
        saveToFirebase(controller: self, image: photoImage, imageName: account, message: account, database: self.databaseRef)
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isNewPhoto = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fullSegue"{
            
            guard let collectionCell = sender as? PhotoCollectionViewCell else {return}
            print(collectionCell.photoView.tag)
            let note = self.memberData[collectionCell.photoView.tag]
            let index = collectionCell.photoView.tag
            
            let fullVC = segue.destination as! fullScreenViewController
            
            fullVC.index = index
            fullVC.currentImage = collectionCell.photoView.image
            fullVC.currentFullData = note
            fullVC.fullScreenData = self.memberData
  
        }
        
        
    }
    

}


extension MemberViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GLCell", for: indexPath) as! PhotoCollectionViewCell
        print(indexPath.row)

        let duc = memberData[indexPath.item]
        if let fileName = duc.imageName {
            print(fileName)
            cell.photoView.tag = indexPath.item
            cell.photoView.image = image(fileName: fileName)
            cell.photoView.layer.cornerRadius = 20
            cell.photoView.layer.shadowOpacity = 0.5
            
        }
        return cell
    }

}

extension MemberViewController : UICollectionViewDelegate {
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("\(indexPath.section),\(indexPath.row)")

    }
}
