


import UIKit
import Firebase
import FirebaseAuth


class HomePageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate ,PostMessageViewControllerDelegate{
    func didPostMessage() {
        refreshLoadData(1)
    }
    

    @IBOutlet weak var tableView: UITableView!

    var data : [DatabaseData] = []
    
    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!
    var refreshControl:UIRefreshControl!
    

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            // 停止 refreshControl 動畫
            self.refreshControl.endRefreshing()
            
            let databaseRefPaper = self.databaseRef.child("Paper")
            databaseRefPaper.observe(.value, with: { [weak self] (snapshot) in
                if let uploadDataDic = snapshot.value as? [String:Any] {
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)

                    self?.data = []
                    for i in 0 ..< keyArray.count {
                        let array = dataDic[keyArray[i]] as! [String:Any]
                        print(array)
                        
                        let note = DatabaseData()
                        note.paperName = keyArray[i]
                        note.imageName = "\(keyArray[i]).jpg"
                        note.account = array["account"] as? String
                        note.message = array["message"] as? String
                        note.date = array["date"] as? String
                        note.url = array["photo"] as? String
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        guard let comment = array["comment"] as? [String:Any] else {return}
                        note.commentCount = comment.count
                        self!.data.append(note)
                        self?.data.sort(by: { (post1, post2) -> Bool in
                            post1.postTime! > post2.postTime!
                        })

                        print(i)
              
                        // PhotoView
                        guard let fileName = note.imageName,
                            let photoName = note.account else {
                            return
                        }
                        if checkFile(fileName: fileName) && checkFile(fileName: "\(photoName).jpg") {
//                            print("file exist.")
                        }else{
                            let databaseImageView = databaseRefPaper.child(keyArray[i]).child("photo")
                            loadImageToFile(fileName: fileName, database: databaseImageView)
                            let databaseUser = self!.databaseRef.child("User").child(note.uid!).child("photo")
                            loadImageToFile(fileName: "\(photoName).jpg", database: databaseUser)
                            
                        }
                    }
//                    self!.refreshLoadData(5)
                    DispatchQueue.main.async {
                        self!.tableView.reloadData()
                    }
                }
                
            })
//            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count + 1
    }
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self.data.count + 1) / (self.data.count + 1))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CustomCellTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "customCell") as? CustomCellTableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCellTableViewCell
            cell?.textLabel?.text = "在想些什麼?"
            if let account = UserDefaults.standard.string(forKey: "account") {
                cell?.imageView?.image = image(fileName: "\(account).jpg")
            }
            return cell!
        }
      
        let dict = self.data[indexPath.section - 1]
        cell?.account.text = dict.account
        cell?.textView.text = dict.message
        cell?.date.text = dict.date
        
        cell?.photoView.image = image(fileName: dict.imageName)
        cell?.photoView.layer.cornerRadius = 30
        cell?.photoView.layer.shadowOpacity = 0.5

        if let account = dict.account {
            cell?.photo.image = image(fileName: "\(account).jpg")
        }
        
        cell?.messageCount.text = "\(dict.commentCount - 1)則留言"
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        print("\(indexPath.section), \(indexPath.row)")
        
    }
    
    
    
    
    @IBAction func heartBtn(_ sender: Any) {
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let home = self.data[indexPath.section - 1]
                let navigationVC = segue.destination as! UINavigationController
                let messageVC = navigationVC.topViewController as! MessageViewController
                messageVC.messageData = home
                
            }
            
        }
        
    }
    
}

