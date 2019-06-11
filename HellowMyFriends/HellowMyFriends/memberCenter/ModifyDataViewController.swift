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
    func didFinihModifyImage(imageData : ImageData)
}


class ModifyDataViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    var modifyData : UserData!
    var modifyImage : ImageData!
    
    
    var formatter: DateFormatter! = nil
    
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
        
        self.password.placeholder = "請輸入6-10位英數字"
        self.nickname.placeholder = "此App使用的名字,最多五個字"
        self.birthday.placeholder = "ex:1911/01/01"
        
        
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let myDatePicker = UIDatePicker()
        myDatePicker.datePickerMode = .date
        myDatePicker.date = NSDate() as Date
        // 設置 UIDatePicker 改變日期時會執行動作的方法
        myDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        // 將 UITextField 原先鍵盤的視圖更換成 UIDatePicker
        birthday.inputView = myDatePicker
        birthday.tag = 200
    }
    
    @objc func datePickerChanged(datePicker:UIDatePicker) {
        // 依據元件的 tag 取得 UITextField
        let myTextField = self.view?.viewWithTag(200) as? UITextField
        // 將 UITextField 的值更新為新的日期
        myTextField?.text = formatter.string(from: datePicker.date)
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
        self.modifyData.userNickname = self.nickname.text
        self.modifyData.userBirthday = self.birthday.text
        self.modifyImage.image = self.imageView.image
        
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
        guard self.modifyData.userBirthday?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        
        self.delegate?.didFinishModifyData(userData: self.modifyData)
        self.delegate?.didFinihModifyImage(imageData:self.modifyImage)
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
