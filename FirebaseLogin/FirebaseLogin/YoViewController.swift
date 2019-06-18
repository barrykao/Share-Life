//
//  YoViewController.swift
//  FirebaseLogin
//
//  Created by Michael on 2019/6/18.
//  Copyright © 2019 Zencher. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class YoViewController: UIViewController {

    lazy var ref = Database.database().reference()
    @IBOutlet weak var inputField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        var refHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String:Any]
            let dataArray = postDict!["data"] as? [String]
            print(dataArray![2])
        })

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func sendData(_ sender: Any) {
        ref.setValue(["name":"michael", "data":["a","b","c","d","e"]])

    }
}
