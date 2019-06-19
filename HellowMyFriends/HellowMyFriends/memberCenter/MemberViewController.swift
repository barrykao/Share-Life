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
    
    @IBOutlet weak var photo: UIImageView!

    
    @IBOutlet weak var signOutBtn: UIButton!
    
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
      
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.uid)
            print("已登入")
            self.account.text = UserDefaults.standard.string(forKey: "account")
            
            print("顯示圖片")
            self.loadImage()
            
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
        self.account.isEnabled = false
        buttonDesign(button: signOutBtn)
        buttonDesign(button: cameraBtn)
        buttonDesign(button: self.account)
        
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
            modifyVC.delegate = self
    }

    
    func didFinishModifyImage(image: UIImage?) {
        self.photo.image = image
    }
    
    func loadImage() {
        
        let fileName = "\(self.account.text!).jpg"
        if checkFile(fileName: fileName){
            self.photo.image = image(fileName: fileName)
        }else{
            let databaseRef = Database.database().reference()
            databaseRef.child("UserAccount").child(uid).child("photo").observe(.value) { (snapshot) in
                if let urlString = snapshot.value as? String {
                    if let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        let session = URLSession.shared
                        let task = session.dataTask(with: request) { (data, response, error) in
                            if let e = error {
                                print("error \(e)")
                            }
                            if let imageData = data {
                                DispatchQueue.main.async {
                                    self.photo.image = thumbmailImage(image: UIImage(data: imageData)!, fileName: fileName)
                                }
                            }
                        }
                        task.resume()
                    }
                }
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
