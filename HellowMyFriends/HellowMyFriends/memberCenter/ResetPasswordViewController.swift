//
//  ResetPasswordViewController.swift
//  
//
//  Created by 高琨淯 on 2019/6/13.
//

import UIKit
import Firebase
import FirebaseAuth
import MessageUI

class ResetPasswordViewController: UIViewController ,UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!

    
    @IBOutlet weak var sendBtn: UIButton!
    
    
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.delegate = self
        buttonDesign(button: sendBtn)
        buttonDesign(button: backBtn)
        
        textFieldClearMode(textField: emailText)
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func send(_ sender: Any) {
        
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            if self.emailText.text == "" {
                alertAction(controller: self, title: "警告", message: "請輸入E-mail")
            } else {
                Auth.auth().sendPasswordReset(withEmail: self.emailText.text!, completion: { (error) in
                    if error == nil {
                        self.emailText.text = ""
                        alertActionDismiss(controller: self, title: "成功", message: "已成功將驗證信件寄送至您的信箱")
                    } else {
                        alertAction(controller: self, title: "失敗", message: "請輸入正確的E-mail")
                    }
                })
            }
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "連線中斷", message: "請確認您的網路連線是否正常，謝謝!")
        }
        
    }

    @IBAction func back(_ sender: Any) {
        
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
