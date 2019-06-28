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

class ModifyDataViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet weak var photo: UIImageView!
    
    var photoImageView : UIImage?
    
    var isNewPhoto : Bool = false
    var storageRef : StorageReference!
    var databaseRef : DatabaseReference!
    var account : String = UserDefaults.standard.string(forKey: "account")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
        self.photo.image = self.photoImageView
        self.navigationItem.rightBarButtonItem?.isEnabled = false

    
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        let alert = UIAlertController(title: "編輯相片", message: "儲存成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            let fileName = "\(self.account).jpg"
            self.photo.image = thumbmailImage(image: self.photo.image! , fileName: fileName)
            self.databaseRef = self.databaseRef.child("User").child(self.uid)
            saveToFirebase(controller: self, image: self.photo.image, imageName: self.account, message: self.account, database: self.databaseRef)
            
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
        guard let image = info[.originalImage] as? UIImage else {return}
        DispatchQueue.main.async {
            self.photo.image = image
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isNewPhoto = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
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
