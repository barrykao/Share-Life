


import UIKit
import Firebase
import FirebaseAuth
import AudioToolbox.AudioServices //加入震動反饋


class HomePageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!

    var data : [DatabaseData] = []
    var databaseRef : DatabaseReference!
    var refreshControl:UIRefreshControl!
    var touchedIndexPath : Int = 0
    var uid: String?
    
    var flag: Bool = false
    var feedbackGenerator : UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .heavy)
    deinit {
        feedbackGenerator = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        databaseRef = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else { return}
        self.uid = uid
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData(1)
        feedbackGenerator?.prepare()

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        refreshLoadData(1)
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
            
            let databaseRefPaper = self.databaseRef.child("Paper")
            databaseRefPaper.observe(.value, with: { [weak self] (snapshot) in
                if let uploadDataDic = snapshot.value as? [String:Any] {
                    let dataDic = uploadDataDic
                    let keyArray = Array(dataDic.keys)
                    self?.data = []
                    for i in 0 ..< keyArray.count {
                        let array = dataDic[keyArray[i]] as! [String:Any]
                        let note = DatabaseData()
                        note.paperName = keyArray[i]
                        note.imageName = "\(keyArray[i]).jpg"
                        note.account = array["account"] as? String
                        note.message = array["message"] as? String
                        note.date = array["date"] as? String
                        note.url = array["photo"] as? String
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        
                        if array["comment"] as? String == "commentData" {
//                            print("0則留言")
                            note.commentCount = 0
                        }else {
                            guard let comment = array["comment"] as? [String:Any] else {return}
                            note.commentCount = comment.count
                        }
                        if array["heart"] as? String == "heartData" {
//                            print("0顆愛心")
                            note.heartCount = 0
                        }else {
                            guard let heart = array["heart"] as? [String:Any] else {return}
                            note.heartUid = Array(heart.keys)
                            note.heartCount = heart.count
//
//                            for j in 0 ..< note.heartCount {
//                                if self!.uid == note.heartUid[j] {
//                                    note.flag = true
//                                    print(self!.uid!)
//                                }
//                            }
                            
                        }
                        self!.data.append(note)
                        self?.data.sort(by: { (post1, post2) -> Bool in
                            post1.postTime! > post2.postTime!
                        })
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CustomCellTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "customCell") as? CustomCellTableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCellTableViewCell
            cell?.textLabel?.text = "想與我們分享些什麼嗎?"
            if let account = UserDefaults.standard.string(forKey: "account") {
                cell?.imageView?.image = image(fileName: "\(account).jpg")
            }
            return cell!
        }
      
        let note = self.data[indexPath.section - 1]
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

        cell?.heartImageBtn.tag = indexPath.section * 10
        cell?.heartImageBtn.addTarget(self, action: #selector(heartBtnPressed), for: .touchDown)

        cell?.heartCount.setTitle("\(note.heartCount)顆愛心", for: .normal)
        cell?.heartCount.tag = indexPath.section
        

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        print("\(indexPath.section), \(indexPath.row)")
        
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
 
        if segue.identifier == "heartSegue" {
         print("heartSegue")
            guard let index = sender as? UIButton else {return}
            let indexPath = index.tag
            print(indexPath)
            let home = self.data[indexPath - 1]
            let navigationVC = segue.destination as! UINavigationController
            let heartVC = navigationVC.topViewController as! HeartViewController
            heartVC.messageData = home
        }
        
    }

    @objc func heartBtnPressed(sender:UIButton ) {
        
        
        let indexPath = (sender.tag) / 10
        let note = self.data[indexPath - 1]
        guard let paperName = note.paperName else { return}
        guard let account = UserDefaults.standard.string(forKey: "account") else { return}
        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
        
        
        
        if !note.flag {
//        if sender.imageView?.image == UIImage(named: "emptyHeart") {
            DispatchQueue.main.async {
                sender.setImage(UIImage(named: "fullHeart"), for: .normal)
            }
            let heart: [String : Any] = ["postTime": [".sv":"timestamp"],"account" : account,"uid" : self.uid!]
            
            databasePaperName.child("heart").child(self.uid!).setValue(heart)
            { (error, database) in
                if let error = error {
                    assertionFailure("Fail To postMessage \(error)")
                }
//                print("上傳愛心成功")
            }
        }else {
            
            DispatchQueue.main.async {
                sender.setImage(UIImage(named: "emptyHeart"), for: .normal)
            }
            
            databasePaperName.observe(.value, with: { (snashot) in
                    // delete Heart
            databasePaperName.child("heart").child("\(self.uid!)").removeValue { (error, data) in
//                    print("刪除愛心成功")
//                    print("\(self.uid!) take your heart!")
                
                        // add fake Heart
                    databasePaperName.observe(.value, with: { (snapshot) in
                        if (snapshot.hasChild("heart")){
                            print("heart alive")
                        }else{
                            print("heart died")
                            databasePaperName.child("heart").setValue("heartData", withCompletionBlock: { (error, data) in
                                //                            print("上傳假資料成功")
                            })
                        }
                    }) { (error) in
                        print("error: \(error)")
                    }
                }
                
            })
        }
        
//        self.tableView.reloadData()


        
        
        

//        func scaleLikeButton() {
//            UIView.animate(withDuration: 0.2, animations: {
//                let scaleTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//                sender.transform = scaleTransform
//            }) { ( _ ) in
//                UIView.animate(withDuration: 0.2, animations: {
//                    sender.transform = CGAffineTransform.identity
//                })
//            }
//        }
//
//        scaleLikeButton()
//
//        feedbackGenerator?.impactOccurred()

        
    }
    
}

