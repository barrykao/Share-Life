//
//  LockViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/29.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LockViewController: UIViewController {

    
    
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var tableView: UITableView!
    
    var lockPaper: [PaperData] = []
    var refreshControl:UIRefreshControl!
    var databaseRef: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        databaseRef = Database.database().reference()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData()
        
        // Do any additional setup after loading the view.
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
            
            let databaseRefPaper = self.databaseRef.child("Paper")
            databaseRefPaper.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let uploadDataDic = snapshot.value as? [String:Any] else {return}
                let dataDic = uploadDataDic
                let keyArray = Array(dataDic.keys)
                self.lockPaper = []
                
                for i in 0 ..< keyArray.count {
                    guard let array = dataDic[keyArray[i]] as? [String:Any] else {return}
                    let note = PaperData()
                    note.account = array["account"] as? String
                    if let blockUid = array["blockUid"] as? [String] {
                        note.blockUid = blockUid
                    }
                    self.lockPaper.append(note)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    


}
extension LockViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.lockPaper.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let note = self.lockPaper[indexPath.row]
        if note.blockUid.count != 0 {
            cell.textLabel?.text = note.nickName
            if let account = note.account {
                let fileName = "\(account).jpg"
                let image = loadImage(fileName: "\(fileName).jpg")
                cell.imageView?.image = image
            }
        }
        
        return cell
        
    }
    
}
