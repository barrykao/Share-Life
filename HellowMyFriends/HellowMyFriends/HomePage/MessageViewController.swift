//
//  MessageViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/16.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
//import MessageUI

protocol MessageViewControllerDelegate: class {
    func didUpdateMessage(note: PaperData)
}

class MessageViewController: UIViewController {

    
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet var message: UILabel!
    
    @IBOutlet var postBtn: UIButton!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var nickName: UILabel!
    
    var databaseRef: DatabaseReference!
    var messageData: PaperData!
    var commentData: [CommentData] = []
    var refreshControl:UIRefreshControl!
    var isEdit: Bool = false
    var delegate: MessageViewControllerDelegate?
    var index: Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        guard let nickName = messageData.nickName else {return}
        self.nickName.text = nickName
        
        textView.delegate = self
        databaseRef = Database.database().reference()
        // Photo
        guard let messageAccount = messageData.account else {return}
        photo.image = loadImage(fileName:"\(messageAccount).jpg" )
        // Meesage
        message.text = messageData.message
        self.postBtn.isEnabled = false
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
//        self.view.addGestureRecognizer(tap) // to Replace "TouchesBegan"

        textView.text = "留言......"
        textView.textColor = UIColor.lightGray
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5.0
     
        textView.returnKeyType = .done
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData()
        
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    func refreshLoadData() {
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            refreshControl.beginRefreshing()
            // 使用 UIView.animate 彈性效果，並且更改 TableView 的 ContentOffset 使其位移
            // 動畫結束之後使用 loadData()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.height)
            }) { (finish) in
                self.loadData()
            }
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "連線中斷", message: "請確認您的網路連線是否正常，謝謝!")
        }
      
        
    }
    
    @objc func loadData(){
        // 這邊我們用一個延遲讀取的方法，來模擬網路延遲效果（延遲3秒）
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            // 停止 refreshControl 動畫
            self.refreshControl.endRefreshing()
            
            guard let paperName = self.messageData.paperName else { return}
            let databaseRefPaper = self.databaseRef.child("Paper").child(paperName).child("comment")
            databaseRefPaper.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let uploadDataDic = snapshot.value as? [String:Any] else {return}
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)
                    self?.commentData = []
                    self?.messageData.commentNameArray = keyArray
                    for i in 0 ..< keyArray.count {
                        let array = dataDic[keyArray[i]] as! [String:Any]
                        print(array)
                        let note = CommentData()
                        note.commentName = keyArray[i]
                        note.account = array["account"] as? String
                        note.comment = array["comment"] as? String
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        note.nickName = array["nickName"] as? String

                        self?.commentData.append(note)
                        self?.commentData.sort(by: { (post1, post2) -> Bool in
                            post1.postTime ?? 0.0 > post2.postTime ?? 0.0
                        })
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
            })
        }
    }
    
    @IBAction func postBtn(_ sender: Any) {
        
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            guard let paperName = messageData.paperName else {return}
            let databasePaper = self.databaseRef.child("Paper")
            databasePaper.observeSingleEvent(of: .value) { (snapshot) in
                guard let paperNameDict = snapshot.value as? [String:Any] else {return}
                let paperNameArray = Array(paperNameDict.keys)
                if paperNameArray.contains(paperName) {
                    guard let uid = Auth.auth().currentUser?.uid else { return}
                    guard let account = UserDefaults.standard.string(forKey: "account") else { return}
                    guard let nickName = UserDefaults.standard.string(forKey: "nickName") else { return}
                    guard let comment = self.textView.text else {return}
                    self.messageData.commentCount += 1
                    let note = CommentData()
                    
                    let postMessage: [String : Any] = [ "comment" : comment,
                                                        "postTime": [".sv":"timestamp"],
                                                        "account" : account,
                                                        "uid" : uid,
                                                        "nickName" :nickName]
                    self.databaseRef.child("Paper").child(paperName).child("comment").child(note.commentUUID).setValue(postMessage) { (error, database) in
                        if let error = error {
                            assertionFailure("Fail To postMessage \(error)")
                        }
                        print("上傳留言成功")
                        self.loadData()
                    }
                    self.textView.text = ""
                    self.dismissKeyBoard()
                    self.delegate?.didUpdateMessage(note: self.messageData)
                    
                }else {
                    let alert = UIAlertController(title: "警告", message: "請貼文已刪除或修改!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .default, handler: { (ok) in
                        self.dismiss(animated: true)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "連線中斷", message: "請確認您的網路連線是否正常，謝謝!")
        }
        
        
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)

    }
    
    func isEditing() {
        if textView.text != "留言......"{
            self.postBtn?.isEnabled = true
        }else if isEdit {
            self.postBtn?.isEnabled = true
        }
    }
    
}

extension MessageViewController: UITableViewDataSource, UITableViewDelegate{
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        let note = self.commentData[indexPath.row]
        if let accountView = note.account ,
            let nickName = note.nickName {
            cell.account.text = nickName
            cell.photo.image = loadImage(fileName: "\(accountView).jpg")
            cell.message.text = note.comment
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        print("\(indexPath.section), \(indexPath.row)")
        let note = self.commentData[indexPath.row]
        self.index = indexPath.row
        guard let paperName = messageData.paperName else {return}
//        guard let nickName = note.nickName else {return}
        guard let commentName = note.commentName else {return}
//        guard let comment = note.comment else {return}
        let commentNameArray = messageData.commentNameArray
        let databasePaper = self.databaseRef.child("Paper")
        databasePaper.observeSingleEvent(of: .value) { (snapshot) in
            guard let paperNameDict = snapshot.value as? [String:Any] else {return}
            let paperNameArray = Array(paperNameDict.keys)
            if paperNameArray.contains(paperName) {
                if commentNameArray.contains(commentName) {
                    guard let uid = UserDefaults.standard.string(forKey: "uid") else {return}
                    if note.uid == uid {
                        
                        let controller = UIAlertController(title: "刪除留言功能", message: "請問是否確認刪除此留言", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                            print("Yes")
                            guard let paperName = self.messageData.paperName else { return}
                            guard let commentName = note.commentName else {return}
                            let databasePaperName = self.databaseRef.child("Paper").child(paperName)
                            databasePaperName.child("comment").child(commentName).removeValue(completionBlock: { (error, data) in
                                print("刪除留言成功")
                                self.commentData.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                alertAction(controller: self, title: "刪除留言功能", message: "刪除成功")

                            })
                            
                        }
                        controller.addAction(okAction)
                        let cancelAction = UIAlertAction(title: "No", style: .destructive , handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        
                    }else {
                        /*
                        /*
                        let controller = UIAlertController(title: "留言", message: "請選擇操作", preferredStyle: .actionSheet)
                        let action = UIAlertAction(title: "檢舉留言", style: .default) { (action) in
                            
                            if MFMailComposeViewController.canSendMail(){
                                let mailController = MFMailComposeViewController()
                                mailController.mailComposeDelegate = self
                                mailController.setSubject("檢舉留言")
                                mailController.setToRecipients(["barrykao881@gmail.com"])
                                mailController.setMessageBody("發文文章：\(paperName)\n留言文章：\(commentName)\n留言人姓名：\(nickName)\n留言訊息：\(comment)\n檢舉原因：", isHTML: false)
                                self.present(mailController, animated: true, completion: nil)
                            }else {
                                print("send mail Fail!")
                            }
                        }
                        controller.addAction(action)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        */
                        let controller = UIAlertController(title: "檢舉功能", message: "請問是否確認檢舉此留言", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                            print("Yes")
                            alertAction(controller: self, title: "送出成功", message: "後續客服會進行查證，謝謝")
                        }
                        controller.addAction(okAction)
                        let cancelAction = UIAlertAction(title: "No", style: .destructive , handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        */
                    }
                }else {
                    print("請留言已刪除!")
                    let alert = UIAlertController(title: "警告", message: "請留言已刪除!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .default, handler: { (ok) in
                        self.refreshLoadData()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }else {
                alertActionDismiss(controller: self, title: "警告", message: "請貼文已刪除或修改!")

            }
            
        }
        
        
    }
    
    
}

/*
//MARK:MFMailComposeViewControllerDelegate
extension MessageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if result == .sent {
            alertActionDismiss(controller: controller, title: "回報問題", message: "感謝您的意見回饋，我們會盡快處理!")
            let note = self.commentData[self.index]
            guard let paperName = self.messageData.paperName else { return}
            guard let commentName = note.commentName else {return}
            let databasePaperName = self.databaseRef.child("Paper").child(paperName)
            databasePaperName.child("comment").child(commentName).removeValue(completionBlock: { (error, data) in
                print("刪除留言成功")
                self.refreshLoadData()
            })
            
        }
        
        if result == .cancelled {
            controller.dismiss(animated: true)
        }
        if result == .saved {
            alertAction(controller: controller, title: "儲存草稿", message: "草稿儲存成功")
        }
    }
    
    
}
*/
extension MessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "留言......" {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
   
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == "留言......" || textView.text == ""{
            self.postBtn?.isEnabled = false
        }else{
            self.postBtn?.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing()
        if textView.text == "" {
            textView.text = "留言......"
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    
   
}
