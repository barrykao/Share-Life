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

class PostMessageViewController: UIViewController ,UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{


    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    
    var imageName : String = UUID().uuidString
    
    var isEdit : Bool = false
    
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var uid : String?
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        let uid = Auth.auth().currentUser!.uid
        self.uid = uid
        let account = UserDefaults.standard.string(forKey: "account")
        let imageName = "\(account!).jpg"
        photo.image = image(fileName: imageName)
        
        self.account.text = account
        buttonDesign(button: textView)
        
        textView.delegate = self
        textView.text = "在想些什麼?"
        textView.textColor = UIColor.lightGray
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        // Do any additional setup after loading the view.
       
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "在想些什麼?"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
        if textView.text == "在想些什麼?" && imageView.image != UIImage(named: "blank.png") {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
   
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing()

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        isEditing()

    }
    
    @IBAction func postToServer(_ sender: Any) {
        
        print(imageName)
        let alert = UIAlertController(title: "發送貼文", message: "發送成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
        
            if let image = self.imageView.image {
                let fileName = "\(self.imageName).jpg"
                //write file
                if let imageData = image.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
                        // Save to storage
                        let now:Date = Date()
                        // 建立時間格式
                        let dateFormat:DateFormatter = DateFormatter()
                        dateFormat.dateFormat = "yyyy-MM-dd"
                    
                        // 將當下時間轉換成設定的時間格式
                        let dateString:String = dateFormat.string(from: now)
                        print(dateString)
                    self.storageRef = Storage.storage().reference().child(self.account.text!).child(fileName)
                        let metadata = StorageMetadata()
                        self.storageRef.putData(imageData, metadata: metadata) { (data, error) in
                            if error != nil {
                                print("Error: \(error!.localizedDescription)")
                                return
                            }
                            self.storageRef.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    print("Error: \(error!.localizedDescription)")
                                    return
                                }
                                if let uploadImageUrl = url?.absoluteString{
                                    print("Photo Url: \(uploadImageUrl)")
                                    // Save to Database
                                    let userAccount = ["message" :self.textView.text ?? "" ,self.imageName : uploadImageUrl ] as [String:Any]
                                    self.databaseRef.child("Paper").child(dateString).child(self.uid!).child(self.imageName).setValue(userAccount, withCompletionBlock: { (error, dataRef) in
                                        
                                        if error != nil{
                                            print("Database Error: \(error!.localizedDescription)")
                                        }else{
                                            print("圖片已儲存")
                                        }
                                    })
                                }
                            })
                        }
                }
                self.dismiss(animated: true)
            }
        
        }
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func camera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        //        imagePicker.allowsEditing = true
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
        
        let image = info[.originalImage] as! UIImage
        let fileName = "\(imageName).jpg"
        DispatchQueue.main.async {
            self.imageView.image = thumbmailImage(image: image, fileName: fileName)
        }
        self.isEdit = true
        self.dismiss(animated: true, completion: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    func isEditing() {
        if textView.text != "在想些什麼?"{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else if isEdit {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
