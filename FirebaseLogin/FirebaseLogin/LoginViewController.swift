//
//  LoginViewController.swift
//  FirebaseLogin
//
//  Created by Michael on 2019/6/18.
//  Copyright © 2019 Zencher. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: "123@zencher.com",
                           password: "abc1234")
        { (user, error) in
            if error == nil {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "YoVC")
                self.present(vc!, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Error",
                                                        message: error?.localizedDescription,
                                                        preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }

    }
}
