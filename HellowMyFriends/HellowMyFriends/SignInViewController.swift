//
//  SignInViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/13.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {

    var user : [UserData] = []
    var image : [ImageData] = []
    
    var isSignIn : Bool = true
    
    
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil {
            
            self.storyboard?.instantiateViewController(withIdentifier: "member")
        }
    }
    
    
    @IBAction func SignIn(_ sender: Any) {
        
        
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
                        self.isSignIn = false

                    })
                    
                }else{
                    self.photo.image = UIImage(named: "member.png")

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
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
