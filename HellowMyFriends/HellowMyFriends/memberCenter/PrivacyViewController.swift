//
//  PrivacyViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/20.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var agreeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        agreeBtn.isEnabled = false
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5.0
        textView.delegate = self
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        agreeBtn.isEnabled = true

    }
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true)
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
