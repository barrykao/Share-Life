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
import MessageUI
class SignInViewController: UIViewController ,UITextFieldDelegate ,RegisterViewControllerDelegate {
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var resetPwdBtn: UIButton!
    
    @IBOutlet var reportBtn: UIButton!
    
    var databaseRef: DatabaseReference! = Database.database().reference()
    var nickName: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageViewController.finishUpdate(notification:)), name: Notification.Name("AccountUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func finishUpdate(notification : Notification) {
        
        let note = notification.userInfo?["account"] as! PaperData
        self.account.text = note.account
        nickName = note.nickName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.account.delegate = self
        self.password.delegate = self
        self.account.text = UserDefaults.standard.string(forKey: "account")
        self.password.text = UserDefaults.standard.string(forKey: "password")
        self.nickName = UserDefaults.standard.string(forKey: "nickName")
        buttonDesign(button: signInBtn)
        buttonDesign(button: registerBtn)
        buttonDesign(button: resetPwdBtn)
        buttonDesign(button: reportBtn)
        buttonDesign(button: self.account)
        buttonDesign(button: self.password)
        
        self.password.text = ""
        textFieldClearMode(textField: account)
        textFieldClearMode(textField: password)
        
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
//        checkInternet(controller: self)
    
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            UserDefaults.standard.set(self.account.text, forKey: "account")
            UserDefaults.standard.set(self.password.text, forKey: "password")
            UserDefaults.standard.set(self.nickName, forKey: "nickName")
            
            guard self.account.text != "" && self.password.text != "" else {
                alertAction(controller: self, title: "警告", message: "有空格尚未填寫!")
                return
            }
            Auth.auth().signIn(withEmail: self.account.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    print("log in!")
                    let alert = UIAlertController(title: "登入成功", message: "觀迎來到Share Life!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .default, handler: { (ok) in
                        self.dismiss(animated: true)
                    })
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    UserDefaults.standard.set(uid, forKey: "uid")
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    alertAction(controller: self, title: "錯誤", message: "帳號或密碼錯誤!")
                }
            }
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "連線中斷", message: "請確認您的網路連線是否正常，謝謝!")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let registerVC = segue.destination as? RegisterViewController
        registerVC?.delegate = self
        
    }
    
    func didFinishRegister(account: String?, password: String?, nickName: String?) {
        self.account.text = account
        self.password.text = password
        self.nickName = nickName
    }
    
    
    @IBAction func report(_ sender: Any) {
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            if MFMailComposeViewController.canSendMail(){
                let mailController = MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.setSubject("回報問題")
                mailController.setToRecipients(["barrykao881@gmail.com"])
                mailController.setMessageBody("問題：", isHTML: false)
                self.present(mailController, animated: true, completion: nil)
            }else {
                print("send mail Fail!")
            }
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "連線中斷", message: "請確認您的網路連線是否正常，謝謝!")
            
        }
       
        
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

//MARK:MFMailComposeViewControllerDelegate
extension SignInViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if result == .sent {
            alertActionDismiss(controller: controller, title: "回報問題", message: "感謝您的意見回饋，我們會盡快處理!")
        }
        
        if result == .cancelled {
            controller.dismiss(animated: true)
        }
        if result == .saved {
            alertAction(controller: controller, title: "儲存草稿", message: "草稿儲存成功")
        }
    }
}
