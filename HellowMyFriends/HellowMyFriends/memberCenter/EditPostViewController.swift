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




class EditPostViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    var editData : DatabaseData! = DatabaseData()
    
    
    @IBOutlet var photo: UIImageView!

    @IBOutlet var account: UILabel!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var imageView: UIImageView!
    
    var editImage: UIImage?
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var isEdit : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        
        let account = "\(editData.account!).jpg"
        photo.image = image(fileName: account)
        self.account.text = editData.account
        self.textView.text = editData.message
        self.imageView.image = editImage
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        // Do any additional setup after loading the view.
//        textView.text = "在想些什麼?"
        textView.textColor = UIColor.lightGray
        //        textView.font = UIFont(name: "verdana", size: 13.0)
        textView.returnKeyType = .done
        textView.delegate = self
    }
    

    @IBAction func saveData(_ sender: Any) {
        
        if self.textView.text == "在想些什麼?"{
            self.textView.text = ""
        }
        self.editData.message = self.textView.text
    
        guard let fileName = self.editData.paperName else {return}
        print(fileName)
        
        // save To file
        guard let image1 = thumbmail(image: self.imageView.image!) else {return}
        self.imageView.image = thumbmailImage(image: image1, fileName: "\(fileName).jpg")
        
        
        // save To Server
//        self.databaseRef = self.databaseRef.child("Paper").child(fileName)
//        saveToFirebase(controller: self, image: self.imageView.image, imageName: fileName, message: self.textView.text, database: self.databaseRef)
        self.dismiss(animated: true)
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
        
        guard let image = info[.originalImage] as? UIImage else {return}
        DispatchQueue.main.async {
            self.imageView.image = image
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: true, completion: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
        
        
    
    
    
    
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
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
