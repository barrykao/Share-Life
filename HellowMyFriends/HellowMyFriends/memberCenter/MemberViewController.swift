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
import SDWebImage


class MemberViewController: UIViewController ,UITextFieldDelegate, ModifyDataViewControllerDelegate{
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var photo: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
      
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.uid)
            print("已登入")
            self.account.text = UserDefaults.standard.string(forKey: "account")
            self.password.text = UserDefaults.standard.string(forKey: "password")
            let fileName = "\(self.account.text!).jpg"
            print("顯示圖片")
            
            
            let storageRef = Storage.storage().reference().child("UserPhoto").child(fileName)
            storageRef.downloadURL { url, error in
                guard let url = url else { return }
                self.photo.sd_setImage(with: url, placeholderImage: UIImage(named: "member.png"), completed:nil)
            }
            self.photo.image = checkImage(fileName: fileName)
            
            /*
            databaseRef = Database.database().reference()
            let uid = Auth.auth().currentUser!.uid
            databaseRef.child("UserAccount").child("\(uid)").child("photo").observe(.value) { (snapshot) in
                if let name = snapshot.value as? String {
                    DispatchQueue.main.async {
                        self.photo.image = checkImage(fileName: name)
                    }
                }
            }
            */
        }else{
            print("尚未登入")
            if let signVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as? SignInViewController
            {
                present(signVC, animated: true, completion: nil)
            }
        }
        
    }
    
    var databaseRef : DatabaseReference!
       
    override func viewDidLoad() {
        super.viewDidLoad()

        self.account.delegate = self
        self.password.delegate = self
        self.account.isEnabled = false
        self.password.isEnabled = false
        
        
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            let modifyVC = segue.destination as! ModifyDataViewController
//            modifyVC.photo.image = self.photo.image
            modifyVC.delegate = self
    }

    
    func didFinishModifyImage(image: UIImage?) {
        self.photo.image = image
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
