//
//  SignInViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/15.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController ,UITextFieldDelegate ,RegisterViewControllerDelegate {
    

    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var resetPwdBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.account.delegate = self
        self.password.delegate = self
        self.account.text = UserDefaults.standard.string(forKey: "account")
        self.password.text = UserDefaults.standard.string(forKey: "password")
        buttonDesign(button: signInBtn)
        buttonDesign(button: registerBtn)
        buttonDesign(button: resetPwdBtn)
        buttonDesign(button: self.account)
        buttonDesign(button: self.password)

        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func SignIn(_ sender: Any) {
        
        UserDefaults.standard.set(self.account.text, forKey: "account")
        UserDefaults.standard.set(self.password.text, forKey: "password")
        guard self.account.text != "" && self.password.text != "" else {
            isEmpty(controller: self)
            return
        }
        
        
        Auth.auth().signIn(withEmail: self.account.text!, password: self.password.text!) { (user, error) in
            
            if error == nil {
                    print("log in!")
                    let alert = UIAlertController(title: "登入成功", message: "你好", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: { (ok) in
//                    self.user.insert(str, at: 0)
                    self.dismiss(animated: true)
                })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)

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
        
        let registerVC = segue.destination as? RegisterViewController
        registerVC?.delegate = self
        
    }
    
    func didFinishRegister(account: String?, password: String?) {
        self.account.text = account
        self.password.text = password
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
