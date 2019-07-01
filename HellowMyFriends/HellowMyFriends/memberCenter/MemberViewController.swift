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

class MemberViewController: UIViewController, UIImagePickerControllerDelegate ,UINavigationControllerDelegate{

    
    @IBOutlet var account: UILabel!

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var imageBtn: UIButton!
    
    
    
    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    var currentData: [DatabaseData] = []
    var refreshControl:UIRefreshControl!
    var isNewPhoto : Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        

        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 10)
        
        buttonDesign(button: self.account)
        refreshControl = UIRefreshControl()

        // collectionView
        collectionViewReloadData()

        
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
        print("viewDidAppear")
        
        if Auth.auth().currentUser != nil {
            print("登入成功")
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            self.account.text = account
            print("顯示圖片")
            
            let fileName = "\(account).jpg"
            if checkFile(fileName: fileName) {
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

            // collectionView
            collectionViewReloadData()

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
    
    func collectionViewReloadData() {
        let databaseRefPaper = Database.database().reference().child("Paper")
        databaseRefPaper.observe(.value, with: { (snapshot) in
            if let uploadDataDic = snapshot.value as? [String:Any] {
                let dataDic = uploadDataDic
                let keyArray = Array(dataDic.keys)
                
                self.currentData = []
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
   
                            self.currentData.append(note)
                            // sort Post
                            self.currentData.sort(by: { (post1, post2) -> Bool in
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

}


extension MemberViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GLCell", for: indexPath) as! PhotoCollectionViewCell
        print(indexPath.row)
        
        let duc = currentData[indexPath.item]
        if let fileName = duc.imageName {
            print(fileName)
            cell.photoView.image = image(fileName: fileName)
            cell.photoView.layer.cornerRadius = 20
            cell.photoView.layer.shadowOpacity = 0.5
        }
        return cell
    }

}

extension MemberViewController : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller = UIAlertController(title: "修改貼文", message: "請選擇操作功能", preferredStyle: .actionSheet)
        let names = ["編輯貼文", "刪除貼文"]
        for name in names {
            let action = UIAlertAction(title: name, style: .default) { (action) in
                if action.title == "編輯貼文" {
                    if let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "EditPostVC") as? UINavigationController
                    {
                        print("編輯貼文")
                        let current = self.currentData[indexPath.item]
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
                        let current = self.currentData[indexPath.item]
                        
                        let storageRefAccount = self.storageRef.child(self.account.text!)
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
                    }
                    controller.addAction(okAction)
                    let cancelAction = UIAlertAction(title: "No", style: .destructive , handler: nil)
                    controller.addAction(cancelAction)
                    self.present(controller, animated: true, completion: nil)
                    
                    
                    
                    
                }
            }
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
          
    }
    
}
