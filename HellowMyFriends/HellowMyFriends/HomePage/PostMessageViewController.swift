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
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    var currentName : DatabaseData!
    
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
            
            for i in 0 ..< self.images.count {
                let uuidString = UUID().uuidString
                self.currentName.paperName = uuidString
                guard let fileName = self.currentName.paperName else {return}
                print(fileName)
                // save To file
                guard let image1 = thumbmail(image: self.images[i]) else {return}
                guard let image2 = thumbmailImage(image: image1, fileName: "\(fileName).jpg") else {return}
                
//                self.delegate?.didPostMessage(note: self.currentName)
                // save To Server
                self.databaseRef = self.databaseRef.child("Paper").child(fileName)
                saveToFirebase(controller: self, image: image2, imageName: fileName, message: self.textView.text, database: self.databaseRef)
            }
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
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
