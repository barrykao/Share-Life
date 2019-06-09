//
//  MemberViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/8.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController ,UITextFieldDelegate ,AddNewAccountViewControllerDelegate ,ModifyDataViewControllerDelegate{
  
    
    
    var data : [UserData] = []
    var isSignIn : Bool = true
    
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var nickname: UITextField!
    
    @IBOutlet weak var birthday: UITextField!
    
    @IBOutlet weak var singIn: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var modifyData: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        self.nickname.delegate = self
        self.birthday.delegate = self
   
        self.nickname.isUserInteractionEnabled = false
        self.birthday.isUserInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.modifyData.isEnabled = false

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
            self.isSignIn = false
            self.navigationItem.rightBarButtonItem?.title = "登出"
//            self.tabBarController?.selectedIndex = 0
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.account.isUserInteractionEnabled = false
            self.password.isUserInteractionEnabled = false
            self.modifyData.isEnabled = true
            
        }else{
            self.isSignIn = true
            self.clear()
            self.navigationItem.rightBarButtonItem?.title = "登入"
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.imageView.image = UIImage(named: "member.png")
            self.account.isUserInteractionEnabled = true
            self.password.isUserInteractionEnabled = true
            self.modifyData.isEnabled = false

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
        
        if segue.identifier == "modifySegue"{
            
            let member = UserData()
            member.userAccount = self.account.text
            member.userPassword = self.password.text
            member.userNickname = self.nickname.text
            member.userBirthday = self.birthday.text
            member.image = self.imageView.image
            
            let modifyVC = segue.destination as! ModifyDataViewController
            modifyVC.modifyData = member
            modifyVC.delegate = self
            
        }
        
        
    }
    
    func didFinishAdd(userData: UserData) {
        
        print("didFinishAdd")
        
            self.account.text = userData.userAccount
            self.password.text = userData.userPassword
            self.nickname.text = userData.userNickname
            self.birthday.text = userData.userBirthday
        
    }
    
    func didFinishModify(userData: UserData) {
        
        print("didFinishModify")
        
        self.password.text = userData.userPassword
        self.nickname.text = userData.userNickname
        self.birthday.text = userData.userBirthday
        self.imageView.image = userData.image
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
