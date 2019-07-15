


import UIKit
import Firebase
import FirebaseAuth
import AudioToolbox.AudioServices //加入震動反饋


class HomePageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var data : [DatabaseData] = []
    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!


    var refreshControl:UIRefreshControl!
    var touchedIndexPath : Int = 0
    /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageViewController.finishUpdate(notification:)), name: Notification.Name("updated"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
     @objc func finishUpdate(notification : Notification) {
     
         let note = notification.userInfo?["note"] as! DatabaseData
        
         if let index = self.data.firstIndex(of: note){
         //轉成indexPath
         let indexPath = IndexPath(row: index, section: 0)
         //tableciew reload indexPath位置的cell
         self.tableView.reloadRows(at: [indexPath], with: .automatic)
         }
     
     }
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        let app:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.data = app.data
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData(1)
       
        // load photoImageViewToFile
        databaseRef = Database.database().reference()
        databaseRef.child("User").observe(.value) { (snapshot) in
            
            guard let uploadDataDic = snapshot.value as? [String:Any] else {return}
            let dataDic = uploadDataDic
            let keyArray = Array(dataDic.keys)
            for i in 0 ..< keyArray.count {
                let array = dataDic[keyArray[i]] as! [String:Any]
                let databasePhoto = self.databaseRef.child("User").child(keyArray[i]).child("photo")
                guard let photoName = array["account"] as? String else {return}
                loadImageToFile(fileName: "\(photoName).jpg", database: databasePhoto)
            }
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.loadData()
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
                        note.account = array["account"] as? String
                        note.message = array["message"] as? String
                        note.date = array["date"] as? String
                        note.imageName = array["photo"] as! [String]
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        note.nickName = array["nickName"] as? String

                        if array["comment"] as? String == "commentData" {
                            note.commentCount = 0
                        }else {
                            guard let comment = array["comment"] as? [String:Any] else {return}
                            note.commentCount = comment.count
                        }
                        if array["heart"] as? String == "heartData" {
                            note.heartCount = 0
                        }else {
                            guard let heart = array["heart"] as? [String:Any] else {return}
                            note.heartUid = Array(heart.keys)
                            note.heartCount = heart.count
                        }

                        self!.data.append(note)
                        self?.data.sort(by: { (post1, post2) -> Bool in
                            post1.postTime! > post2.postTime!
                        })
                         for j in 0 ..< note.imageName.count {
                         // loadImageToFile
                            let fileName = "\(note.imageName[j]).jpg"
                            if checkFile(fileName: fileName) {
                                print(fileName)
                            }else {
                                guard let storageRefPhoto = self?.storageRef.child(note.account!).child(fileName) else {return}
                                
                                storageRefPhoto.getData(maxSize: 1*1024*1024) { (data, error) in
                                    guard let imageData = data else {return}
                                    let filePath = fileDocumentsPath(fileName: fileName)
                                    do {
                                        try imageData.write(to: filePath)
                                        print("下載成功")
                                        if j == note.imageName.count {
                                            DispatchQueue.main.async {
                                                self?.tableView.reloadData()
                                            }
                                        }
                                    }catch{
                                        print("error: \(error)")
                                    }
                                }
                            }
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
                
            })
            
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
        
            if let account = UserDefaults.standard.string(forKey: "account"),
               let nickName = UserDefaults.standard.string(forKey: "nickName") {
                cell?.textLabel?.text = nickName
                cell?.imageView?.image = loadImage(fileName: "\(account).jpg")
            }
            cell?.detailTextLabel?.text = "想與我們分享些什麼嗎?"
            return cell!
        }
        
        cell?.collectionViewData = self.data
        
        let note = self.data[indexPath.section - 1]
        cell?.currentData = note
        cell?.collectionView.delegate = cell
        cell?.collectionView.dataSource = cell
        cell?.collectionView.reloadData()
        if note.imageName.count > 1 {
            cell?.pageControl.numberOfPages = note.imageName.count
            cell?.pageControl.isUserInteractionEnabled = true
            cell?.pageControl.tintColor = UIColor.gray
            cell?.pageControl.pageIndicatorTintColor = UIColor.gray
            cell?.pageControl.currentPageIndicatorTintColor = UIColor.blue
        }else {
            cell?.pageControl.numberOfPages = 0
        }
        
        cell?.account.text = note.nickName
        cell?.label.text = note.message
        cell?.date.text = note.date
        if let account = note.account {
            cell?.photo.image = loadImage(fileName: "\(account).jpg")
        }
        
        if note.imageName.count > 1 {
            cell?.photoCount.image = UIImage(named: "pictures")
        }else{
            cell?.photoCount.image = nil
        }
        
        let uid = Auth.auth().currentUser?.uid
        
        cell?.heartImageBtn.setImage(UIImage(named: "fullHeart"), for: .normal)
       
        
        cell?.heartImageBtn.tag = indexPath.section * 10
        cell?.heartImageBtn.addTarget(self, action: #selector(heartBtnPressed), for: .touchDown)
        

        cell?.heartCount.setTitle("\(note.heartCount)顆愛心", for: .normal)
        cell?.heartCount.tag = indexPath.section
    
        cell?.messageCount.setTitle("\(note.commentCount)則留言", for: .normal)
        cell?.messageCount.tag = indexPath.section
        cell?.messageBtn.tag = indexPath.section
        
        
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
            let home = self.data[indexPath - 1]
            let navigationVC = segue.destination as! UINavigationController
            let messageVC = navigationVC.topViewController as! MessageViewController
            messageVC.messageData = home
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

    @objc func heartBtnPressed(sender:UIButton) {
        

        
        guard let account = UserDefaults.standard.string(forKey: "account") else { return}
        guard let nickName = UserDefaults.standard.string(forKey: "nickName") else {return}
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {return}

        let indexPath = (sender.tag) / 10
        let note = self.data[indexPath - 1]
        guard let paperName = note.paperName else { return}

//        guard let paperName = note.paperName else { return}
//        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
        
        let heart: [String : Any] = ["postTime": [".sv":"timestamp"],
                                     "account" : account,
                                     "uid" : uid,
                                     "nickName" : nickName]
        databasePaperName.child("heart").child(uid).setValue(heart){ (error, database) in
            if let error = error {
                assertionFailure("Fail To postMessage \(error)")
            }
            print("上傳巧克力成功")
        }
    
        /*
        databasePaperName.child("heart").observe(.value) { (snapshot) in
            
            if (snapshot.hasChild(uid)) {
                // delete heart
                sender.setImage(UIImage(named: "emptyHeart"), for: .normal)
                databasePaperName.child("heart").child(uid).removeValue(completionBlock: { (error, data) in
                    print("刪除離留言成功")
                    // give fake heart
                    databasePaperName.observe(.value, with: { (snapshot) in
                        if (snapshot.hasChild("heart")){
                            print("heart alive")
                        }else{
                            print("heart died")
                            databasePaperName.child("heart").setValue("heartData", withCompletionBlock: { (error, data) in
                                print("上傳假資料成功")
                                self.refreshLoadData(1)
                            })
                        }
                    })
                })
            
            }else {
                //
                sender.setImage(UIImage(named: "fullHeart"), for: .normal)

                 let heart: [String : Any] = ["postTime": [".sv":"timestamp"],
                                             "account" : account,
                                             "uid" : uid,
                                             "nickName" : nickName]
                databasePaperName.child("heart").child(uid).setValue(heart)
                { (error, database) in
                    if let error = error {
                        assertionFailure("Fail To postMessage \(error)")
                    }
                    print("上傳巧克力成功")
                }
                
            }
 
 
        }
         */
        
        /*
            for i in 0 ..< note.heartUid.count {
                    // delete heart
                databasePaperName.child("heart").child(uid).removeValue(completionBlock: { (error, data) in
                    print("刪除離留言成功")
                    // give fake heart
                    databasePaperName.observe(.value, with: { (snapshot) in
                        if (snapshot.hasChild("heart")){
                            print("comment alive")
                        }else{
                            print("comment died")
                            databasePaperName.child("heart").setValue("heartData", withCompletionBlock: { (error, data) in
                                print("上傳假資料成功")
                                self.refreshLoadData(1)
                            })
                        }
                    })
                })
            }
            */
            
            
            
            
        
 
        /*
        // give heart
        guard let paperName = note.paperName else { return}
        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
        let heart: [String : Any] = ["postTime": [".sv":"timestamp"],
                                     "account" : account,
                                     "uid" : uid,
                                     "nickName" : nickName]
        databasePaperName.child("heart").child(uid).setValue(heart)
        { (error, database) in
            if let error = error {
                assertionFailure("Fail To postMessage \(error)")
            }
            print("上傳巧克力成功")
        }
        
        
        
        
        databasePaperName.child("heart").child(uid).removeValue(completionBlock: { (error, data) in
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
        })
        */
        
    

        
    }
    
    
    
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
