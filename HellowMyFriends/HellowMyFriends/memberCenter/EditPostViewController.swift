//
//  EditPostViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/28.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import ImagePicker
import Lightbox

class EditPostViewController: UIViewController {

    var editData : DatabaseData! = DatabaseData()
    
    
    @IBOutlet var photo: UIImageView!

    @IBOutlet var account: UILabel!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var currentName: DatabaseData! = DatabaseData()
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var isEdit : Bool = false
    var images: [UIImage] = []
    let fullScreenSize = UIScreen.main.bounds.size

    override func viewDidLoad() {
        super.viewDidLoad()

        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let account = "\(editData.account!).jpg"
        photo.image = loadImage(fileName: account)
        self.account.text = editData.account
        self.textView.text = editData.message
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        // Do any additional setup after loading the view.
//        textView.text = "在想些什麼?"
        textView.textColor = UIColor.lightGray
        //        textView.font = UIFont(name: "verdana", size: 13.0)
        textView.returnKeyType = .done
        textView.delegate = self
    }
    

    @IBAction func saveData(_ sender: Any) {
        let alert = UIAlertController(title: "發送貼文", message: "發送成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            if self.textView.text == "在想些什麼?"{
                self.textView.text = ""
            }
            
            self.currentName.message = self.textView.text
            
            self.postPhotoBtn()
            
            
            
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
      
    }
    func postPhotoBtn() {
        
        
        
        
        
        self.databaseRef = self.databaseRef.child("Paper").child(self.currentName.imageName[0])
        print("postPhotoBtn")
        for i in 0 ..< self.images.count {
            let uuidString = UUID().uuidString
            self.currentName.imageName.append(uuidString)
            guard let fileName = self.currentName.imageName.first else {return}
            print(fileName)
            // save To file
            guard let image1 = thumbmail(image: self.images[i]) else {return}
            guard let image2 = thumbmailImage(image: image1, fileName: "\(fileName).jpg") else {return}
            // save To Server
            guard let imageData = image2.jpegData(compressionQuality: 1) else {return}
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            self.storageRef = Storage.storage().reference().child(account).child("\(fileName).jpg")
            let metadata = StorageMetadata()
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
                    self.currentName.imageURL.append(uploadImageUrl)
                    
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
                                                       "photo" : self.currentName.imageName,
                                                       "photourl" : self.currentName.imageURL,
                                                       "postTime": [".sv":"timestamp"],
                                                       "comment" : "commentData",
                                                       "heart" : "heartData"]
                    
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
    
    @IBAction func camera(_ sender: Any) {
        
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
        
    
    
    
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
   

}

extension EditPostViewController: UICollectionViewDataSource {
    
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



extension EditPostViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return fullScreenSize
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension EditPostViewController : ImagePickerDelegate {
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapperDidPress")
        
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            LightboxImage(image: $0)
        }
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("doneButtonDidPress")
        self.images = images
        self.dismiss(animated: true)
        self.collectionView.reloadData()
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancelButtonDidPress")
        imagePicker.dismiss(animated: true)
    }
}



extension EditPostViewController : UITextViewDelegate {
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
