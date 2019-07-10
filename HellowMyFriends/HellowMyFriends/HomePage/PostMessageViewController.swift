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
    func didPostMessage(note : DatabaseData)
}

class PostMessageViewController: UIViewController ,UITextViewDelegate{

    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    var currentName : DatabaseData!
    
    var images : [UIImage] = []
    var imageNames: [String] = []
    var urlStrings: [String] = []
    var isEdit : Bool = false
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var delegate: PostMessageViewControllerDelegate?
    let fullScreenSize = UIScreen.main.bounds.size
    var index: Int!
    var pageControl : UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        currentName = DatabaseData()
        
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
        pageControl.currentPageIndicatorTintColor = UIColor.black
        view.addSubview(self.pageControl)
        
        if let account = UserDefaults.standard.string(forKey: "account") {
            let photoName = "\(account).jpg"
            photo.image = image(fileName: photoName)
            self.account.text = account
        }
        
        buttonDesign(button: textView)
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        textView.text = "在想些什麼?"
        textView.textColor = UIColor.lightGray
//        textView.font = UIFont(name: "verdana", size: 13.0)
        textView.returnKeyType = .done
        textView.delegate = self
        
        
    }
    
    @IBAction func postToServer(_ sender: Any) {
        
        let alert = UIAlertController(title: "發送貼文", message: "發送成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            if self.textView.text == "在想些什麼?"{
                self.textView.text = ""
            }
            self.currentName.message = self.textView.text
         
                self.postPhotoBtn()
                self.databaseRef = self.databaseRef.child("Paper").child(self.imageNames[0])
                self.uploadToDatabase()

            
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
   
    func postPhotoBtn() {
        
        print("postPhotoBtn")
        for i in 0 ..< self.images.count {
            let uuidString = UUID().uuidString
            self.currentName.paperName = uuidString
            guard let fileName = self.currentName.paperName else {return}
            print(fileName)
            // save To file
            guard let image1 = thumbmail(image: self.images[i]) else {return}
            guard let image2 = thumbmailImage(image: image1, fileName: "\(fileName).jpg") else {return}
            self.imageNames.append(fileName)
            // save To Server
            guard let imageData = image2.jpegData(compressionQuality: 1) else {return}
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            self.storageRef = Storage.storage().reference().child(account).child("\(fileName).jpg")
            let metadata = StorageMetadata()
            self.storageRef.putData(imageData, metadata: metadata)
            self.storageRef.putData(imageData, metadata: metadata) { (data, error) in
                print("執行putData")
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                self.storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    print("執行downloadURL")
                    guard let uploadImageUrl = url?.absoluteString else {return}
                    self.urlStrings.append(uploadImageUrl)
                    
                    let now: Date = Date()
                    let dateFormat:DateFormatter = DateFormatter()
                    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString:String = dateFormat.string(from: now)
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    guard let message = self.textView.text else { return}
                    guard let account = UserDefaults.standard.string(forKey: "account") else {return}
                    let postMessage: [String : Any] = ["account" : account,
                                                       "date" : dateString,
                                                       "message" : message,
                                                       "uid" : uid,
                                                       "photo" : self.imageNames,
                                                       "photourl" : self.urlStrings,
                                                       "postTime": [".sv":"timestamp"],
                                                       "comment" : "commentData",
                                                       "heart" : "heartData"]
                    
                    print("\(self.imageNames) : \(self.urlStrings)")
                    self.databaseRef.setValue(postMessage) { (error, data) in
                        if error != nil {
                            assertionFailure()
                        }else {
                            print("上傳成功")
                        }
                    }
                })
            }
        }
    }
    
    func uploadToDatabase() {
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "在想些什麼?" {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
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
            textView.font = UIFont(name: "verdana", size: 13.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        isEditing()
    }
    
    func isEditing() {
        if textView.text != "在想些什麼?"{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else if isEdit {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
   
}

extension PostMessageViewController: UICollectionViewDataSource {
    
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
    
}
extension PostMessageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.index = indexPath.item
        
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
