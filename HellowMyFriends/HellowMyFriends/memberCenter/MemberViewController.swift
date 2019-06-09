//
//  MemberViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/8.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController ,UITextFieldDelegate ,AddNewAccountViewControllerDelegate{
    
    var data : [UserData] = []
    var isSignIn : Bool = true
    
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var nickname: UITextField!
    
    @IBOutlet weak var birthday: UITextField!
    
    
    @IBOutlet weak var signIn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        self.nickname.delegate = self
        self.birthday.delegate = self
   
        self.nickname.isUserInteractionEnabled = false
        self.birthday.isUserInteractionEnabled = false
        
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
        
        //MARK:
        guard str.userAccount?.isEmpty != true else{
            isEmpty(controller: self)
            return
        }
        guard str.userAccount!.count > 5 && str.userAccount!.count < 10 else {
            judge(controller: self)
            return
        }
        guard str.userPassword?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        guard str.userPassword!.count > 5 && str.userPassword!.count < 10 else {
            judge(controller: self)
            return
        }
        
        if isSignIn {
            self.signIn.setTitle("登出", for: .normal)
            self.isSignIn = false
            self.tabBarController?.selectedIndex = 0
        }else{
            self.isSignIn = true
            self.clear()
            self.signIn.setTitle("登入", for: .normal)
        }
        
        
        
    }

    func clear () {
        
        self.account.text = ""
        self.password.text = ""
        self.nickname.text = ""
        self.birthday.text = ""
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSegue" {
 
            let member = UserData()
            
            let addVC = segue.destination as! AddNewAccountViewController
            addVC.currentData = member
            addVC.delegate = self
        }
        
    }
    
    func didFinishAdd(userData: UserData) {
        
        print("didFinishAdd")
        
            self.account.text = userData.userAccount
            self.password.text = userData.userPassword
            self.nickname.text = userData.userNickname
            self.birthday.text = userData.userBirthday
        
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
