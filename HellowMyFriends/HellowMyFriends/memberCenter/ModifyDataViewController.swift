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
import FirebaseStorage


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

    @IBAction func saveData(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "編輯大頭貼", message: "儲存成功", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
        if let image = self.photo.image, self.isNewPhoto {
            
            let photoName = UserDefaults.standard.string(forKey: "account")
            
                //儲存照片
                //建立照片路徑，存的位置, String轉URL一定要用fileURLWithPath
                let homeURL = URL(fileURLWithPath: NSHomeDirectory())
                let documents = homeURL.appendingPathComponent("Documents")
                let fileName = "\(photoName!).png"
                let fileURL = documents.appendingPathComponent(fileName)
            
                if let imageData = image.jpegData(compressionQuality: 1) {
                    do{
                        try imageData.write(to: fileURL, options: [.atomicWrite])
                        self.storageRef.child("UserPhoto").child("\(fileName)").putFile(from: fileURL)
                    }catch{
                        print("error \(error)")
                    }
                }
            }
//            let photodict = ["photo":self.photo.image]
//            self.ref.child("UserAccount").child("\(uid)").setValue(photodict)
            
            self.delegate?.didFinishModifyImage(image: self.photo.image)
            self.dismiss(animated: true)
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
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.photo.image = image
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
