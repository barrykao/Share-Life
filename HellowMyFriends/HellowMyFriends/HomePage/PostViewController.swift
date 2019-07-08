//
//  PostViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/23.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import ImagePicker
import Lightbox

class PostViewController: UIViewController {

    @IBOutlet var photoView: UIImageView!
    
    @IBOutlet var clearPhotoBtn: UIBarButtonItem!
    
    var currentImage : DatabaseData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        if photoView.image != nil {
            clearPhotoBtn.isEnabled = true

        }
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
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {return}
        DispatchQueue.main.async {
            self.photoView.image = image
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: true, completion: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    */
    @IBAction func back(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    
    @IBAction func clearPhotoBtn(_ sender: Any) {
        
        if photoView.image != nil {
            photoView.image = nil
            clearPhotoBtn.isEnabled = false

        }
        
    }
    
    
}

extension PostViewController : ImagePickerDelegate {
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapperDidPress")
        
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            LightboxImage(image: $0)
        }
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
        
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
        imagePicker.dismiss(animated: true)
        self.dismiss(animated: true)
    }
    
    
}
