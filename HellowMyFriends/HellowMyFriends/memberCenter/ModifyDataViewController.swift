//
//  ModifyDataViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/9.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
protocol ModifyDataViewControllerDelegate : class{
    func didFinishModify(userData:UserData)
}


class ModifyDataViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    var modifyData : UserData!
    
    weak var delegate : ModifyDataViewControllerDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var account: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var nickname: UITextField!
    
    
    @IBOutlet weak var birthday: UITextField!
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.account.text = self.modifyData.userAccount
        self.account.isEnabled = false
        self.password.text = ""
        self.nickname.text = self.modifyData.userNickname
        self.birthday.text = self.modifyData.userBirthday
        

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveData(_ sender: Any) {
        
        self.modifyData.userPassword = self.password.text
        self.modifyData.userNickname = self.nickname.text
        self.modifyData.userBirthday = self.birthday.text
        self.modifyData.image = self.imageView.image
        
        // Password
        guard self.modifyData.userPassword?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        guard self.modifyData.userPassword!.count > 5 && self.modifyData.userPassword!.count < 10 else {
            judge(controller: self)
            return
        }
        // Nickname
        guard self.modifyData.userNickname?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        guard self.modifyData.userNickname!.count < 6 else {
            judgeNickName(controller: self)
            return
        }
        
        
        self.delegate?.didFinishModify(userData: self.modifyData)
        self.navigationController?.popViewController(animated: true)
        
    }
    

    
    @IBAction func clearData(_ sender: Any) {
        
        self.password.text = ""
        self.nickname.text = ""
        self.birthday.text = ""
        
    }
    
    
    @IBAction func modifyBirth(_ sender: Any) {
        
        let dateValue = DateFormatter()
        dateValue.dateFormat = "yyyy/MM/dd" // 設定要顯示在Text Field的日期時間格式
        birthday.text = dateValue.string(from: datePicker.date) // 更新Text Field的內容
    }
    
    
    
    @IBAction func camera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.imageView.image = image
        
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
