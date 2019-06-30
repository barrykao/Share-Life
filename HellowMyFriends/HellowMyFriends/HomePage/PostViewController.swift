//
//  PostViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/23.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import ImagePicker

class PostViewController: UIViewController {// ,UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet var photoView: UIImageView!
    
    var currentImage : DatabaseData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentImage = DatabaseData()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "postSegue" {

            let image = self.photoView.image
            let postVC = segue.destination as! PostMessageViewController
            postVC.image1 = image
        }
        
    }
    
    
    @IBAction func camera(_ sender: Any) {
        /*
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
        */
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {return}
        DispatchQueue.main.async {
            self.photoView.image = image
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: true, completion: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
}

extension PostViewController : ImagePickerDelegate {
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapperDidPress")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("doneButtonDidPress")
        guard let image = images.first else {return}
        self.photoView.image = image
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.dismiss(animated: true)
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancelButtonDidPress")
        self.dismiss(animated: true)
    }
    
    
}
