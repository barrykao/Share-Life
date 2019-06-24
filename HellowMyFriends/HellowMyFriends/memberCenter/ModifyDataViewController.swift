//
//  ModifyDataViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/9.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage


//protocol ModifyDataViewControllerDelegate : class {
//    func didFinishModifyImage(image:UIImage?)
//}

class ModifyDataViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
//    weak var delegate : ModifyDataViewControllerDelegate?
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    
    var isNewPhoto : Bool = false
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var account : String = UserDefaults.standard.string(forKey: "account")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        buttonDesign(button: saveBtn)
        buttonDesign(button: cameraBtn)
        buttonDesign(button: backBtn)
        saveBtn.isEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let photoName = UserDefaults.standard.string(forKey: "account"){
            let fileName = "\(photoName).jpg"
            self.photo.image = checkImage(fileName: fileName)
        }
    }
    

    @IBAction func saveData(_ sender: Any) {
        
        let alert = UIAlertController(title: "編輯相片", message: "儲存成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            /*
            if let image = self.photo.image{
                let fileName = "\(self.account!).jpg"
                    if let imageData = image.jpegData(compressionQuality: 1) {//compressionQuality:0~1之間
                            // Save to storage
                            self.storageRef = Storage.storage().reference().child(self.account!).child(fileName)
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
                                        let userAccount = ["id" : self.account! , "photo" : uploadImageUrl ]
                                        self.databaseRef.child("UserAccount").child(self.uid).setValue(userAccount, withCompletionBlock: { (error, dataRef) in
                                            
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
                self.delegate?.didFinishModifyImage(image: image)
                self.dismiss(animated: true)
            }
            */
            
            
            self.databaseRef = self.databaseRef.child("User").child(self.uid)
            saveToFirebase(controller: self, image: self.photo.image, imageName: self.account, name: self.account, database: self.databaseRef)
            
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
        let fileName = "\(account).jpg"
        DispatchQueue.main.async {
            self.photo.image = thumbmailImage(image: image, fileName: fileName)
        }
        self.isNewPhoto = true
        saveBtn.isEnabled = true
        self.dismiss(animated: true, completion: nil)
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
