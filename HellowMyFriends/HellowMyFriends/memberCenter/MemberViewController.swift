//
//  MemberViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/8.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class MemberViewController: UIViewController ,UITextFieldDelegate ,AddNewAccountViewControllerDelegate , ModifyDataViewControllerDelegate{

    var user : [UserData] = []
    var image : [ImageData] = []
    
    
    var isSignIn : Bool = true
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var photo: UIImageView!

    @IBOutlet weak var modifyDataBtn: UIButton!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        modifyDataBtn.isEnabled = false
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
        let image = ImageData()
        image.image = self.photo.image
        
        guard str.userAccount?.isEmpty != true && str.userPassword?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        
        Auth.auth().signIn(withEmail: self.account.text!, password: self.password.text!) { (user, error) in
            
            if error == nil {
                if self.isSignIn {
                    print("log in!")
                    let alert = UIAlertController(title: "登入成功", message: "你好", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: {
                        self.user.insert(str, at: 0)
                        self.image.insert(image, at: 0)
                        self.modifyDataBtn.isEnabled = true
                        self.registerBtn.isEnabled = false
                        self.signInBtn.setTitle("登出", for: .normal)
                        self.account.isEnabled = false
                        self.password.isEnabled = false
                        self.isSignIn = false
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        

                    })
                    
                }else{
                    let alert = UIAlertController(title: "登出成功", message: "謝謝", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: {
                        if Auth.auth().currentUser != nil {
                            do {
                                try Auth.auth().signOut()
                            } catch let error as NSError {
                                print(error.localizedDescription)
                            }
                        }
                        self.modifyDataBtn.isEnabled = false
                        self.registerBtn.isEnabled = true
                        self.signInBtn.setTitle("登入", for: .normal)
                        self.account.isEnabled = true
                        self.password.isEnabled = true
                        self.isSignIn = true
                        self.photo.image = UIImage(named: "member.png")
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    })
                }
            } else {
                // 提示用戶從 firebase 返回了一個錯誤。
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSegue" {
            let add = UserData()
            let addVC = segue.destination as! AddNewAccountViewController
            addVC.currentData = add
            addVC.delegate = self
            
        }

        if segue.identifier == "modifySegue" {
            let image = self.image.first
            let modifyVC = segue.destination as! ModifyDataViewController
            modifyVC.modifyImage = image
            modifyVC.delegate = self
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
//        self.image.insert(imageData, at: 0)
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
