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

class MessageViewController: UIViewController {

    
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet var message: UILabel!
    
    @IBOutlet var postBtn: UIButton!
    
    @IBOutlet var textView: UITextView!
    
    var databaseRef: DatabaseReference!
    var messageData: DatabaseData! = DatabaseData()
    var commentData: [CommentData] = []
    let commentName: String = UUID().uuidString
    var refreshControl:UIRefreshControl!
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        textView.delegate = self
        databaseRef = Database.database().reference()
        // Photo
        guard let messageAccount = messageData.account else {return}
        photo.image = image(fileName:"\(messageAccount).jpg" )
        // Meesage
        message.text = messageData.message
        self.postBtn.isEnabled = false
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap) // to Replace "TouchesBegan"

        
        textView.text = "留言......"
        textView.textColor = UIColor.lightGray
        textView.returnKeyType = .done
//        animateTable()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData(1)
        
        let swipeLeft = UISwipeGestureRecognizer(
            target:self,
            action:#selector(backBtn(_:)))
        swipeLeft.direction = .right
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeLeft)
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        isEditing()

    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
   
    @IBAction func refreshLoadData(_ sender: Any) {
        
        refreshControl.beginRefreshing()
        // 使用 UIView.animate 彈性效果，並且更改 TableView 的 ContentOffset 使其位移
        // 動畫結束之後使用 loadData()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.height)
        }) { (finish) in
            self.loadData()
        }
        
        
        
        
    }
    
    @objc func loadData(){
        // 這邊我們用一個延遲讀取的方法，來模擬網路延遲效果（延遲3秒）
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            // 停止 refreshControl 動畫
            self.refreshControl.endRefreshing()
            
            guard let paperName = self.messageData.paperName else { return}
            let databaseRefPaper = self.databaseRef.child("Paper").child(paperName).child("comment")
            databaseRefPaper.observe(.value, with: { [weak self] (snapshot) in
                guard let uploadDataDic = snapshot.value as? [String:Any] else {return}
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)  
                    //                    print(dataDic)
                    print(keyArray)
                    self?.commentData = []
                    for i in 0 ..< keyArray.count {
                        let array = dataDic[keyArray[i]] as! [String:Any]
                        print(array)
                        let note = CommentData()
                        note.commentName = keyArray[i]
                        note.account = array["account"] as? String
                        note.comment = array["comment"] as? String
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        self?.commentData.append(note)
                        self?.commentData.sort(by: { (post1, post2) -> Bool in
                            post1.postTime ?? 0.0 > post2.postTime ?? 0.0
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
            })
//                            self.tableView.reloadData()
        }
        
    }
    
    
    
    @IBAction func postBtn(_ sender: Any) {
        
        guard let paperName = self.messageData.paperName else { return}
        guard let message = self.messageData.message else { return}
        guard let uid = Auth.auth().currentUser?.uid else { return}
        guard let account = UserDefaults.standard.string(forKey: "account") else { return}

        print(paperName)
        print(message)
        
        let note = CommentData()
        let postMessage: [String : Any] = [ "comment" : self.textView.text!,
                                            "postTime": [".sv":"timestamp"],
                                            "account" : account,
                                            "uid" : uid
                                          ]
        
        print(self.commentName)
        self.databaseRef.child("Paper").child(paperName).child("comment").child(note.commentUUID).setValue(postMessage) { (error, database) in
            if let error = error {
                assertionFailure("Fail To postMessage \(error)")
            }
            print("上傳留言成功")
        }
        self.textView.text = ""

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

extension MessageViewController: UITableViewDataSource {
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        print(self.commentData.count)
      

        let note = self.commentData[indexPath.row]
        
        if let accountView = note.account {
            cell.textLabel?.text = note.account
            cell.imageView?.image = image(fileName: "\(accountView).jpg")
            cell.detailTextLabel?.text = note.comment
        }
        
        
 
        return cell
    }
}

extension MessageViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        print("\(indexPath.section), \(indexPath.row)")
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        self.tableView.setEditing(editing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let uid = Auth.auth().currentUser?.uid {
            let note = self.commentData[indexPath.row]
            
            if note.uid == uid {
             if editingStyle == .delete {
                 guard let paperName = self.messageData.paperName else { return}
                 guard let commentName = note.commentName else {return}
                
                    let databasePaperName = self.databaseRef.child("Paper").child(paperName)
                    databasePaperName.child("comment").child(commentName).removeValue(completionBlock: { (error, data) in
                    print("刪除離留言成功")
               
//                    self.refreshLoadData(1)
                    })
                
                    databasePaperName.observe(.value, with: { (snapshot) in
//                        print(snapshot.value)
                        if (snapshot.hasChild("comment")){
                            print("comment alive")
                        }else{
                            print("comment died")

                            databasePaperName.child("comment").setValue("commentData", withCompletionBlock: { (error, data) in
                                print("上傳假資料成功")
                                self.commentData = []
                                self.refreshLoadData(1)

                            })
                            
                        }
                    }) { (error) in
                        print("error: \(error)")
                    }
                 }
            }
        }
    }
}


extension MessageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "留言......" {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
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
            textView.font = UIFont(name: "verdana", size: 13.0)
        }
    }
    
   
}
