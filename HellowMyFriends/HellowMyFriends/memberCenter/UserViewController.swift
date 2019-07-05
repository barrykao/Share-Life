//
//  UserViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/4.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{


    @IBOutlet var tableView: UITableView!

    var userData: [DatabaseData]!
    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        databaseRef = Database.database().reference()
//        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        print(self.userData.count)
     
    }
    
  
    

    
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userData.count
    }
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CustomCellTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "customCell") as? CustomCellTableViewCell
        
        let note = self.userData[indexPath.section]
        cell?.account.text = note.account
        cell?.textView.text = note.message
        cell?.date.text = note.date
        
        cell?.photoView.image = image(fileName: note.imageName)
        cell?.photoView.layer.cornerRadius = 30
        cell?.photoView.layer.shadowOpacity = 0.5
        
        if let account = note.account {
            cell?.photo.image = image(fileName: "\(account).jpg")
        }
        
        cell?.messageCount.text = "\(note.commentCount)則留言"
        print(note.commentCount)
        cell?.heartImageBtn.tag = indexPath.section * 10
        cell?.heartImageBtn.addTarget(self, action: #selector(heartBtnPressed), for: .touchDown)
        
        cell?.heartCount.setTitle("\(note.heartCount)顆愛心", for: .normal)
        cell?.heartCount.tag = indexPath.section
        cell?.messageBtn.tag = indexPath.section
        cell?.messageBtn.addTarget(self, action: #selector(messageVC), for: .touchDown)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        print("\(indexPath.section), \(indexPath.row)")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageSegue" {
            guard let index = sender as? UIButton else {return}
            let indexPath = index.tag
            print(indexPath)
            let home = self.userData[indexPath]
            let navigationVC = segue.destination as! UINavigationController
            let messageVC = navigationVC.topViewController as! MessageViewController
            messageVC.messageData = home
            
        }
        
        if segue.identifier == "heartSegue" {
            print("heartSegue")
            guard let index = sender as? UIButton else {return}
            let indexPath = index.tag
            print(indexPath)
            let home = self.userData[indexPath]
            let navigationVC = segue.destination as! UINavigationController
            let heartVC = navigationVC.topViewController as! HeartViewController
            heartVC.messageData = home
            

        }

    }
    
    
    @objc func messageVC (sender: UIButton) {
        print("messageVC")
        print(sender.tag)
        
    }
    
    @objc func heartBtnPressed(sender:UIButton ) {
        
        
        let indexPath = (sender.tag) / 10
        let note = self.userData[indexPath - 1]
        guard let paperName = note.paperName else { return}
        guard let account = UserDefaults.standard.string(forKey: "account") else { return}
        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
        
    }
}
