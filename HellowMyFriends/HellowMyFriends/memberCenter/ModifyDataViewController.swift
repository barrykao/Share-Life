//
//  ModifyDataViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/9.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
protocol ModifyDataViewControllerDelegate : class{
    func didFinishModifyData(userData : UserData)
    func didFinishModifyImage(imageData : ImageData)
}


class ModifyDataViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    var modifyData : UserData!
    var modifyImage : ImageData!
    
    weak var delegate : ModifyDataViewControllerDelegate?
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var password: UITextField!
    
    var isNewPhoto : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.text = self.modifyData.userPassword
        self.photo.image = self.modifyImage.image
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveData(_ sender: Any) {
        
        self.modifyData.userPassword = self.password.text
        self.modifyImage.image = self.photo.image
        // Password
        guard self.modifyData.userPassword?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        let alert = UIAlertController(title: "編輯照片或修改密碼", message: "儲存成功!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            self.delegate?.didFinishModifyData(userData: self.modifyData)
            self.delegate?.didFinishModifyImage(imageData: self.modifyImage)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

   
    @IBAction func camera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
