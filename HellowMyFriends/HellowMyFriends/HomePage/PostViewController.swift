//
//  PostViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/23.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import ImagePicker

class PostViewController: UIViewController {

    @IBOutlet var photoView: UIImageView!
    
    var currentImage : DatabaseData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentImage = DatabaseData()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "postMessageSegue" {
            let image = self.photoView.image
            let postVC = segue.destination as! PostMessageViewController
            postVC.image1 = image
        }
        
    }
    
    
    @IBAction func camera(_ sender: Any) {
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
