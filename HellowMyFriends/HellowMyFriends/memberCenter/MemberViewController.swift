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
    
    @IBOutlet weak var modifyDataBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        self.nickname.delegate = self
        self.birthday.delegate = self
        self.account.placeholder = "請輸入6-10位英數字"
        self.password.placeholder = "請輸入6-10位英數字"

        self.nickname.isUserInteractionEnabled = false
        self.birthday.isUserInteractionEnabled = false
        
        self.modifyDataBtn.isEnabled = false

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
            let alert = UIAlertController(title: "登入成功", message: "歡迎 \(str.userAccount!)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                
                self.queryFromServer()
                self.isSignIn = false
                self.navigationItem.rightBarButtonItem?.title = "登出"
                //            self.tabBarController?.selectedIndex = 0
                
                self.account.isUserInteractionEnabled = false
                self.password.isUserInteractionEnabled = false
                self.modifyDataBtn.isEnabled = true
                
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

        }else{
            let alert = UIAlertController(title: "登出成功", message: "期待您再次使用", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                
                self.isSignIn = true
                self.clear()
                self.navigationItem.rightBarButtonItem?.title = "登入"
                
                self.account.isUserInteractionEnabled = true
                self.password.isUserInteractionEnabled = true
                self.modifyDataBtn.isEnabled = false
                
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
          

        }
   
    }

    func clear () {
        self.account.text = ""
        self.password.text = ""
        self.nickname.text = ""
        self.birthday.text = ""
        self.imageView.image = UIImage(named: "member.png")
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
            let imageData = ImageData()
            member.userAccount = self.account.text
            member.userPassword = self.password.text
            member.userNickname = self.nickname.text
            member.userBirthday = self.birthday.text
            
            
            imageData.image = self.imageView.image
            
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
    
    func didFinishModifyData( userData : UserData ) {
        
        print("didFinishModify")
        
        self.password.text = userData.userPassword
        self.nickname.text = userData.userNickname
        self.birthday.text = userData.userBirthday
        
    }
    
    func didFinihModifyImage(imageData: ImageData) {
        self.imageView.image = imageData.image
    }
    
    func queryFromServer(){
        
        if let url = URL(string: "http://127.0.0.1:8888/Account_json.php"){
            
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let e = error {
                    print("error \(e)")
                }
                guard let jsonData = data else{return}
                print(jsonData)
                let jsonContent = String(data: jsonData, encoding: .utf8)
                print(jsonContent!)
                
                //update core data
                //NSFetchResuletController
                
                let decoder = JSONDecoder()
                do{
                    self.data = try decoder.decode([UserData].self, from: jsonData)
                    
                    
                    
                }catch{
                    print("error while parsing json \(error)")
                }
            }
            task.resume()
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
