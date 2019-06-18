//
//  ResetPasswordViewController.swift
//  
//
//  Created by 高琨淯 on 2019/6/13.
//

import UIKit
import Firebase
import FirebaseAuth


class ResetPasswordViewController: UIViewController ,UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!

    
    @IBOutlet weak var sendBtn: UIButton!
    
    
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.delegate = self
        buttonDesign(button: sendBtn)
        buttonDesign(button: backBtn)
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
        
        if self.emailText.text == "" {
            let alertController = UIAlertController(title: "警告", message: "請輸入E-mail", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().sendPasswordReset(withEmail: self.emailText.text!, completion: { (error) in
                if error == nil {
                    self.emailText.text = ""
                    let alertController = UIAlertController(title: "成功", message: "已成功將驗證信件寄送至您的信箱", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "失敗", message: "請輸入正確的E-mail", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
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
