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


class MemberViewController: UIViewController ,UITextFieldDelegate, ModifyDataViewControllerDelegate{

    
    var image : [ImageData] = []

    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var photo: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.uid)
            print("已登入")
            
        }else{
            print("尚未登入")
            
            if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
            {
                present(signVC, animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.account.text = UserDefaults.standard.string(forKey: "account")
        self.password.text = UserDefaults.standard.string(forKey: "password")
       
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        self.account.isEnabled = false
        self.password.isEnabled = false
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        
        let str = UserData()
        str.userAccount = self.account.text
        str.userPassword = self.password.text
        let image = ImageData()
        image.image = self.photo.image
        
        if Auth.auth().currentUser != nil {
            let alert = UIAlertController(title: "登出成功", message: "謝謝", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                
                if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
                {
                    self.present(signVC, animated: true, completion: nil)
                }
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: {
                        
                do {
                    try Auth.auth().signOut()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
               
            })
                
        }
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "modifySegue" {
            let image = self.image.first
            let modifyVC = segue.destination as! ModifyDataViewController
            modifyVC.modifyImage = image
            modifyVC.delegate = self
        }
        
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
