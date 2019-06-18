//
//  UploadViewController.swift
//  FirebaseLogin
//
//  Created by Michael on 2019/6/18.
//  Copyright © 2019 Zencher. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func uploadImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
}

extension UploadViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
        }
        
        let uniqueString = NSUUID().uuidString
        
        if let selectedImage = selectedImageFromPicker {
            
            print("\(uniqueString), \(selectedImage)")
            
            let storageRef = Storage.storage().reference().child("ImageFireUpload").child("\(uniqueString).png")
            if let uploadData = selectedImage.jpegData(compressionQuality: 1.0) {
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                storageRef.putData(uploadData, metadata: metaData, completion: { (data, error) in
                    
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    // 取得連結
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        if let uploadImageUrl = url?.absoluteString {
                            print("Photo Url: \(uploadImageUrl)")
                                                        
                            let databaseRef = Database.database().reference().child("ImageFireUpload").child(uniqueString)
                            
                            databaseRef.setValue(uploadImageUrl, withCompletionBlock: { (error, dataRef) in
                                
                                if error != nil {
                                    print("Database Error: \(error!.localizedDescription)")
                                } else {
                                    print("圖片已儲存")
                                }
                            })

                        }
                    })
                })
                
                
            }
            
            dismiss(animated: true, completion: nil)
            
        }
    }
}
