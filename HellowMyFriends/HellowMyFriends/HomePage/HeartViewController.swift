//
//  HeartViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/30.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HeartViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var databaseRef: DatabaseReference!
    var messageData: PaperData! = PaperData()
    var heartData: [HeartData] = []
    let heartName: String = UUID().uuidString
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.  refreshControl = UIRefreshControl()
        databaseRef = Database.database().reference()
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData(1)
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
            
            let databaseRefPaper = self.databaseRef.child("Paper").child(paperName).child("heart")
            databaseRefPaper.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                if let uploadDataDic = snapshot.value as? [String:Any] {
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)
                    //                    print(dataDic)
                    print(keyArray)
                    self?.heartData = []
                    for i in 0 ..< keyArray.count {
                        let array = dataDic[keyArray[i]] as! [String:Any]
                        print(array)
                        let note = HeartData()
                        note.heartName = keyArray[i]
                        note.account = array["account"] as? String
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        note.nickName = array["nickName"] as? String
                        self?.heartData.append(note)
                        self?.heartData.sort(by: { (post1, post2) -> Bool in
                            post1.postTime ?? 0.0 > post2.postTime ?? 0.0
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
                
            })
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    
}

extension HeartViewController: UITableViewDataSource {
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.heartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        print(indexPath.row)
        
        
        let note = self.heartData[indexPath.row]
        if let accountView = note.account ,
            let nickName = note.nickName {
            cell.textLabel?.text = nickName
            cell.imageView?.image = loadImage(fileName: "\(accountView).jpg")
            cell.detailTextLabel?.text = "給了你愛心"
        }
        return cell
        
    }
}

extension HeartViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        print("\(indexPath.section), \(indexPath.row)")
        
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        self.tableView.setEditing(editing, animated: false)
    }
    
    
}
