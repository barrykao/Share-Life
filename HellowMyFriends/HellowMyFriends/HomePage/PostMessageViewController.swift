//
//  PostMessageViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/18.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol PostMessageViewControllerDelegate {
    func didPostMessage(note : PaperData)
}

class PostMessageViewController: UIViewController ,UITextViewDelegate{

    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    var currentData : PaperData!
    
    var images : [UIImage] = []
    var isEdit : Bool = false
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var delegate: PostMessageViewControllerDelegate?
    let fullScreenSize = UIScreen.main.bounds.size
    var index: Int!
    var pageControl : UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        
        //设置页控制器
        pageControl = UIPageControl()
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        pageControl.numberOfPages = images.count
        pageControl.isUserInteractionEnabled = true
        pageControl.tintColor = UIColor.gray
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        view.addSubview(self.pageControl)
        guard let nickName = UserDefaults.standard.string(forKey: "nickName") else {return}
        self.account.text = nickName
        self.currentData.nickName = nickName
        if let account = UserDefaults.standard.string(forKey: "account") {
            let photoName = "\(account).jpg"
            self.currentData.account = account
            photo.image = loadImage(fileName: photoName)
        }
        
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5.0
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let item =  UIBarButtonItem(image: UIImage(named: "return"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = item
        self.navigationItem.hidesBackButton = true
        
        
        textView.text = "在想些什麼?"
        textView.textColor = UIColor.lightGray
//        textView.font = UIFont(name: "verdana", size: 13.0)
        textView.returnKeyType = .done
        textView.delegate = self
        
        
    }
    
    @objc func back() {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func postToServer(_ sender: Any) {
        
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            
            let alert = UIAlertController(title: "發送貼文", message: "發送成功", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                
                if self.textView.text == "在想些什麼?"{
                    self.textView.text = ""
                }
                self.currentData.message = self.textView.text
                self.databaseRef = self.databaseRef.child("Paper").child(self.currentData.imageName[0])
                self.postPhotoBtn()
                self.dismiss(animated: true)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "發送失敗", message: "請確認您的網路連線是否正常，謝謝!")
            
        }
        
    }
   
    func postPhotoBtn() {
        
            for i in 0 ..< self.images.count {
                let fileName = self.currentData.imageName[i]
                print(fileName)
                // save To file
                guard let image1 = thumbmail(image: self.images[i]) else {return}
                guard let image2 = thumbmailImage(image: image1, fileName: "\(fileName).jpg") else {return}
                // save To Server
                guard let imageData = image2.jpegData(compressionQuality: 1) else {return}
                guard let account = UserDefaults.standard.string(forKey: "account") else {return}
                let storageFileName = self.storageRef.child(account).child("\(fileName).jpg")
                let metadata = StorageMetadata()
                storageFileName.putData(imageData, metadata: metadata) { (data, error) in
                    print("執行putData")
                    if error != nil {
                        assertionFailure("fail to setValue!")
                        return
                    }
                    let now: Date = Date()
                    let dateFormat:DateFormatter = DateFormatter()
                    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString:String = dateFormat.string(from: now)
                    self.currentData.date = dateString
                    guard let message = self.textView.text else { return}
                    guard let uid = UserDefaults.standard.string(forKey: "uid") else {return}
                    guard let account = UserDefaults.standard.string(forKey: "account") else {return}
                    guard let nickName = UserDefaults.standard.string(forKey: "nickName") else {return}
                    let postMessage: [String : Any] = ["account" : account,
                                                       "nickName" : nickName,
                                                       "date" : dateString,
                                                       "message" : message,
                                                       "uid" : uid,
                                                       "photo" : self.currentData.imageName,
                                                       "postTime": [".sv":"timestamp"]
                    ]
                    self.databaseRef.setValue(postMessage) { (error, data) in
                        if error != nil {
                            assertionFailure("fail to setValue!")
                        }else {
                            print("上傳成功")
                            NotificationCenter.default.post(name: Notification.Name("NoteUpdated"), object: nil, userInfo: ["note": self.currentData!])
                        }
                    }
                }
            }
        
        print("postPhotoBtn")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        isEditing()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "在想些什麼?" {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == "在想些什麼?" || textView.text == ""{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing()
        if textView.text == "" {
            textView.text = "在想些什麼?"
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    func isEditing() {
        if textView.text != "在想些什麼?"{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else if isEdit {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
   
}

extension PostMessageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postMessageCell", for: indexPath) as! PostMessageCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }
    
    //collectionView里某个cell显示完毕
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let visibleCell = collectionView.visibleCells.first else {return}
        self.pageControl.currentPage = collectionView.indexPath(for: visibleCell)!.item
        
    }
    
}


extension PostMessageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return fullScreenSize
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
