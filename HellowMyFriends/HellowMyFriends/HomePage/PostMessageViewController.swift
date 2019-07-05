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
    
    var currentName : DatabaseData!
    
    var image1 : UIImage?
    var isEdit : Bool = false
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var delegate: PostMessageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentName = DatabaseData()
        self.imageView.image = image1
        self.textView.text = currentName.message
        
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        
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
            let uuidString = UUID().uuidString
            self.currentName.paperName = uuidString
            guard let fileName = self.currentName.paperName else {return}
            print(fileName)
            
            // save To file
            guard let image1 = thumbmail(image: self.imageView.image!) else {return}
            self.imageView.image = thumbmailImage(image: image1, fileName: "\(fileName).jpg")
            self.delegate?.didPostMessage(note: self.currentName)
            // save To Server
            self.databaseRef = self.databaseRef.child("Paper").child(fileName)
            saveToFirebase(controller: self, image: self.imageView.image, imageName: fileName, message: self.textView.text, database: self.databaseRef)
            
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
