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
import ImagePicker


class ModifyDataViewController: UIViewController { //, UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

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
            
            
        
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func camera(_ sender: Any) {
      
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func back(_ sender: Any) {

        self.dismiss(animated: true)
    }
    

}
extension ModifyDataViewController : ImagePickerDelegate {
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapperDidPress")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("doneButtonDidPress")
        guard let image = images.first else {return}
        self.photo.image = image
        self.isNewPhoto = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.dismiss(animated: true)

    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancelButtonDidPress")
        self.dismiss(animated: true)
    }
    
    
}
