//
//  MemberViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/8.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController ,UITextFieldDelegate ,AddNewAccountViewControllerDelegate , ModifyDataViewControllerDelegate{

    var data : [UserData] = []
    
    var isSignIn : Bool = true
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var photo: UIImageView!

    @IBOutlet weak var modifyDataBtn: UIButton!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        modifyDataBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        let str = UserData()
        str.userAccount = self.account.text
        str.userPassword = self.password.text
        
        guard str.userAccount?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        guard str.userPassword?.isEmpty != true else{
            isEmpty(controller: self)
            return
        }
        if isSignIn {
            modifyDataBtn.isEnabled = true
            signInBtn.setTitle("登出", for: .normal)
            isSignIn = false
        let alert = UIAlertController(title: "登入成功", message: "你好", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            modifyDataBtn.isEnabled = false
            signInBtn.setTitle("登入", for: .normal)
            isSignIn = true
            let alert = UIAlertController(title: "登出成功", message: "謝謝", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != "addSegue" else{
            let add = UserData()
            let addVC = segue.destination as! AddNewAccountViewController
            addVC.currentData = add
            addVC.delegate = self
            return
        }

        guard segue.identifier != "modfifySegue" else{
            let modifyVC = segue.destination as! ModifyDataViewController
            modifyVC.delegate = self
            return
        }
        
    }
    
    func didFinishAdd(userData: UserData) {
            self.account.text = userData.userAccount
            self.password.text = userData.userPassword
    }
    
    func didFinishModifyData( userData : UserData ) {
        self.password.text = userData.userPassword
    }
    func didFinishModifyImage(imageData: ImageData) {
        self.photo.image = imageData.image
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
