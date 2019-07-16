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
    
    @IBOutlet var photo: UIImageView!

    @IBOutlet var account: UILabel!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var clearPhotoBtn: UIBarButtonItem!
    
    @IBOutlet var cameraBtn: UIBarButtonItem!
    
    var currentData: DatabaseData!
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var isEdit : Bool = false
    var images: [UIImage] = []
    let fullScreenSize = UIScreen.main.bounds.size
    var pageControl : UIPageControl! = UIPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.cameraBtn.isEnabled = false
        let account = "\(currentData.account!).jpg"
        photo.image = loadImage(fileName: account)
        self.account.text = currentData.account
        self.textView.text = currentData.message
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        textView.returnKeyType = .done
        textView.delegate = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //设置页控制器
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        pageControl.numberOfPages = images.count
        pageControl.isUserInteractionEnabled = true
        pageControl.tintColor = UIColor.gray
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        view.addSubview(self.pageControl)
        
    }
    

    @IBAction func saveData(_ sender: Any) {
        let alert = UIAlertController(title: "發送貼文", message: "發送成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            if self.textView.text == "在想些什麼?"{
                self.textView.text = ""
            }
            
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            let storageRefAccount = self.storageRef.child(account)
            let databaseRefPaper = self.databaseRef.child("Paper")
            databaseRefPaper.child(self.currentData.paperName!).removeValue()
            for i in 0 ..< self.currentData.imageName.count {
                let imageName = "\(self.currentData.imageName[i]).jpg"
                storageRefAccount.child(imageName).delete(completion: nil)
                if checkFile(fileName: imageName) {
                    let url = fileDocumentsPath(fileName: imageName)
                    do{
                        try FileManager.default.removeItem(at: url)
                    }catch{
                        print("error: \(error)")
                    }
                }
            }
            
            self.currentData.imageName = []
            for _ in 0 ..< self.images.count {
                let uuidString = UUID().uuidString
                self.currentData.imageName.append(uuidString)
            }
            
            self.currentData.message = self.textView.text
            self.databaseRef = self.databaseRef.child("Paper").child(self.currentData.imageName[0])
            self.postPhotoBtn()
            
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
      
    }
    func postPhotoBtn() {
        
        print("postPhotoBtn")
        for i in 0 ..< self.images.count {
            let fileName = self.currentData.imageName[i]
            print(fileName)
            // save To file
            guard let image1 = thumbmail(image: self.images[i]) else {return}
            guard let image2 = thumbmailImage(image: image1, fileName: "\(fileName).jpg") else {return}
            // save To Server
            guard let imageData = image2.jpegData(compressionQuality: 1) else {return}
            guard let account = UserDefaults.standard.string(forKey: "account") else {return}
            guard let nickName = UserDefaults.standard.string(forKey: "nickName") else {return}
            self.storageRef = Storage.storage().reference().child(account).child("\(fileName).jpg")
            let metadata = StorageMetadata()
            self.storageRef.putData(imageData, metadata: metadata) { (data, error) in
                print("執行putData")
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
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
                                                   "nickName" : nickName,
                                                   "uid" : uid,
                                                   "photo" : self.currentData.imageName,
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
    
    
    @IBAction func clearPhotoBtn(_ sender: Any) {
        
        self.images = []
        self.collectionView.reloadData()
        self.clearPhotoBtn.isEnabled = false
        self.cameraBtn.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.pageControl.numberOfPages = 0
    }
    
}

extension EditPostViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editCell", for: indexPath) as! EditCollectionViewCell
        
        cell.photoView.image = images[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //当前显示的单元格
        //        let visibleCell = collectionView.visibleCells[0]
        guard let visibleCell = collectionView.visibleCells.first else {return}
        //设置页控制器当前页
        self.pageControl.currentPage = collectionView.indexPath(for: visibleCell)!.item
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
        self.navigationItem.rightBarButtonItem?.isEnabled = true
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
    /*
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    */
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == "在想些什麼?" || textView.text == ""{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.clearPhotoBtn.isEnabled = false

        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.clearPhotoBtn.isEnabled = true

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
