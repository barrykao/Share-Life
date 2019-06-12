//
//  CenterViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/11.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit


class CenterViewController: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate{

    
    
    @IBOutlet weak var Photo: UIImageView!
    
    
    @IBOutlet weak var account: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
 
    @IBAction func signOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "登出成功", message: "期待您再次使用", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func modifyPassword(_ sender: Any) {
        
        
        
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
