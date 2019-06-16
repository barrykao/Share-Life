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


protocol ModifyDataViewControllerDelegate : class {
    func didFinishModifyImage(image:UIImage?)
}

class ModifyDataViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    weak var delegate : ModifyDataViewControllerDelegate?
    
    @IBOutlet weak var photo: UIImageView!
    
    var isNewPhoto : Bool = false
    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let photoName = UserDefaults.standard.string(forKey: "account"){
            let fileName = "\(photoName).jpg"
            self.photo.image = checkImage(fileName: fileName)
        }
    }
    

    @IBAction func saveData(_ sender: Any) {

        let alert = UIAlertController(title: "編輯大頭貼", message: "儲存成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
            if let image = self.photo.image, self.isNewPhoto {
                
                if let account = UserDefaults.standard.string(forKey: "account") {
                    let fileName = "\(account).jpg"
                    let fileURL = fileDocumentsPath(fileName: fileName)
                    self.storageRef.child("UserPhoto").child(fileName).putFile(from: fileURL)
                }
                self.delegate?.didFinishModifyImage(image: image)
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
        DispatchQueue.main.async {
            self.photo.image = thumbmailImage(image: image)
        }
        self.isNewPhoto = true
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
