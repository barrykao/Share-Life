


import UIKit
import Firebase
import FirebaseAuth
import AudioToolbox.AudioServices //加入震動反饋

class HomePageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var data : [PaperData] = []
    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!
    var refreshControl:UIRefreshControl!
    let fullScreenSize = UIScreen.main.bounds.size
    var userCardView = UIView()
    var backView = UIView()
    
    var touchedIndexPath : Int = 0
    var feedbackGenerator : UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .heavy)
  
    deinit {
        feedbackGenerator = nil
//        NotificationCenter.default.removeObserver(self)
    }
    
   /*
    @objc func finishUpdate(notification : Notification) {
     
        let note = notification.userInfo?["note"] as! PaperData
        self.data.insert(note, at: 0)
        self.tableView.reloadData()
        
     }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let home: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.data = home.paperData
        feedbackGenerator?.prepare()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()

        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshLoadData(1)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(HomePageViewController.finishUpdate(notification:)), name: Notification.Name("NoteUpdated"), object: nil)

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
                        let note = PaperData()
                        note.paperName = keyArray[i]
                        note.account = array["account"] as? String
                        note.message = array["message"] as? String
                        note.date = array["date"] as? String
                        note.imageName = array["photo"] as! [String]
                        note.uid = array["uid"] as? String
                        note.postTime = array["postTime"] as? Double
                        note.nickName = array["nickName"] as? String
                       
                        if let comment = array["comment"] as? [String:Any] {
                            note.commentCount = comment.count
                        }else {
                            note.commentCount = 0
                        }
                        
                        if let heart = array["heart"] as? [String:Any] {
                            note.heartUid = Array(heart.keys)
                            note.heartCount = heart.count
                        }else {
                            note.heartCount = 0
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
                                        if j == note.imageName.count - 1 {
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
            cell?.pageControl.currentPage = 0
        }else {
            cell?.pageControl.numberOfPages = 0
        }
        
        cell?.account.text = note.nickName
        cell?.label.text = note.message
        cell?.date.text = note.date
        if let account = note.account {
            cell?.photo.image = loadImage(fileName: "\(account).jpg")
            cell?.photo.tag = indexPath.section * 100
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        cell?.photo.isUserInteractionEnabled = true
        cell?.photo.addGestureRecognizer(tapGestureRecognizer)
        
        
        if note.imageName.count > 1 {
            cell?.photoCount.image = UIImage(named: "pictures")
        }else{
            cell?.photoCount.image = nil
        }
        
        cell?.heartImageBtn.setImage(UIImage(named: "fullHeart"), for: .normal)
       
        
        cell?.heartImageBtn.tag = indexPath.section * 10
        cell?.heartImageBtn.addTarget(self, action: #selector(heartBtnPressed), for: .touchUpInside)
        
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            if note.heartUid.contains(uid) {
                cell?.heartImageBtn.setImage(UIImage(named: "fullHeart"), for: .normal)
            }else {
                cell?.heartImageBtn.setImage(UIImage(named: "emptyHeart"), for: .normal)
            }
        }

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
        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
       
        if note.heartUid.contains(uid) {
            // delete
            databasePaperName.child("heart").child(uid).removeValue(completionBlock: { (error, data) in
                if let error = error {
                    assertionFailure("Fail To postMessage \(error)")
                }else {
                    print("刪除離留言成功")
                    DispatchQueue.main.async {
//                     self.loadData()
                    }
                }
            })
        }else {
            // add
            let heart: [String : Any] = ["postTime": [".sv":"timestamp"],
                                         "account" : account,
                                         "uid" : uid,
                                         "nickName" : nickName]
            databasePaperName.child("heart").child(uid).setValue(heart){ (error, database) in
                if let error = error {
                    assertionFailure("Fail To postMessage \(error)")
                }
                print("上傳愛心成功")
                DispatchQueue.main.async {
//                    self.loadData()
                }
            }
        }
        scaleLikeButton(sender: sender)
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let indexPath = tappedImage.tag / 100
        // Your action
        let note = self.data[indexPath - 1]
        
        self.backView.frame = self.view.frame
        self.backView.tag = 997
        self.backView.backgroundColor = UIColor.black
        backView.alpha = 0.3
        self.view.addSubview(self.backView)
        
        let userCardView = UserCardView()
        userCardView.tag = 998
        userCardView.frame = CGRect(x: 12.5, y: 100, width: fullScreenSize.width - 20, height: self.userCardView.frame.size.height)
        userCardView.mainView.layer.cornerRadius = 5.0
        userCardView.mainView.backgroundColor = UIColor.darkGray
        
        userCardView.topView.backgroundColor = UIColor.darkGray
        userCardView.topView.layer.cornerRadius = 5.0
        userCardView.bottomView.backgroundColor = UIColor.darkGray
        userCardView.bottomView.layer.cornerRadius = 5.0

        guard let account = note.account else {return}
        guard let nickName = note.nickName else {return}
        guard let uid = note.uid else {return}
     
        let databaseUser = self.databaseRef.child("User")
        databaseUser.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let uidDict = snapshot.value as? [String:Any] else {return}
            guard let profile = uidDict["profile"] as? String else {return}
            userCardView.photo.image = loadImage(fileName: "\(account).jpg")
            userCardView.photo.layer.cornerRadius = userCardView.photo.bounds.height / 2
            userCardView.nickName.text = nickName
            userCardView.profile.text = profile
            userCardView.nickName.textColor = UIColor.white
            userCardView.profile.textColor = UIColor.white
            UIView.transition(with: self.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {self.view.addSubview(userCardView)}, completion: nil)//加入此視窗
            let cancelBT = UIButton()
            cancelBT.tag = 999
            cancelBT.frame = CGRect(x: self.view.center.x - 25, y: (self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)!) - 100, width: 50, height: 50)
            cancelBT.setImage(UIImage(named: "cancel"), for: .normal)
            cancelBT.addTarget(self, action: #selector(self.dissMissUserCardView), for: .touchUpInside)
            UIView.transition(with: self.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {self.view.addSubview(cancelBT)}, completion: nil)//加入此視窗
        }
    }
    
    @objc func dissMissUserCardView() {
        let back = self.view.viewWithTag(997)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {back?.removeFromSuperview()}, completion: nil)
        let card = self.view.viewWithTag(998)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {card?.removeFromSuperview()}, completion: nil)
        let cancel = self.view.viewWithTag(999)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {cancel?.removeFromSuperview()}, completion: nil)
    }
    
    func scaleLikeButton(sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            let scaleTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            sender.transform = scaleTransform
        }) { ( _ ) in
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
            })
        }
        
        feedbackGenerator?.impactOccurred()
    }

}


