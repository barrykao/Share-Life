


import UIKit
import Firebase
import FirebaseAuth
import AudioToolbox.AudioServices //加入震動反饋
import Lightbox


class HomePageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate ,PostMessageViewControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!

    var data : [DatabaseData] = []
    var databaseRef : DatabaseReference!
    var refreshControl:UIRefreshControl!
    var touchedIndexPath : Int = 0
    var uid: String?
    var lightboxImages: [[LightboxImage]] = [[]]
    var images: [UIImage] = []
    var message: [String] = []
    var postMessageVC: PostMessageViewController = PostMessageViewController()
    var lightboxController: LightboxController = LightboxController()


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
//        animateTable()
    }
    


    override func viewWillAppear(_ animated: Bool) {
        
//        animateTable()

    }
    
    func animateTable() {
        
        self.tableView.reloadData()
        
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: CustomCellTableViewCell = i as! CustomCellTableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: CustomCellTableViewCell = a as! CustomCellTableViewCell
            
            
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), options: .transitionCurlUp, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            index += 1
        }
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
                    self?.images = []
                    self?.message = []
                    self?.lightboxImages = [[]]
                    
                    for i in 0 ..< keyArray.count {
                        
                        let aaa = LightboxImage(image: UIImage())
                        self?.lightboxImages.append([aaa])
                        if i > 0 {
                            self?.lightboxImages[i].remove(at: 0)
                        }
                        
                        let array = dataDic[keyArray[i]] as! [String:Any]
                        let note = DatabaseData()
                        note.paperName = keyArray[i]
                        note.account = array["account"] as? String
                        note.message = array["message"] as? String
                        note.date = array["date"] as? String
                        note.imageName = array["photo"] as! [String]
                        note.imageURL = array["photourl"] as! [String]
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
                        }

                        self!.data.append(note)
                        self?.data.sort(by: { (post1, post2) -> Bool in
                            post1.postTime! > post2.postTime!
                        })
                        
                         for j in 0 ..< note.imageName.count {
                         // PhotoView
                            let fileName = "\(note.imageName[j]).jpg"
                             if checkFile(fileName: fileName) {
                             }else{
                                let databaseImageView = databaseRefPaper.child(keyArray[i]).child("photourl").child("\(i)")
                             loadImageToFile(fileName: fileName, database: databaseImageView)
                             }
                            
                            self?.images.append(loadImage(fileName: "\(note.imageName[j]).jpg")!)
                            
                             print("\(note.imageName[j]).jpg")
                            let lightbox = LightboxImage(image: ((self?.images[j])!), text: note.message!)
                            self?.lightboxImages[i].append(lightbox)
                         
                         }
                        self?.images = []
                        self?.message = []
                        
                        // PhotoView
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
                cell?.imageView?.image = loadImage(fileName: "\(account).jpg")
            }
            return cell!
        }
        
        
        
        let note = self.data[indexPath.section - 1]
        cell?.currentData = note
        cell?.collectionView.delegate = self
        cell?.collectionView.dataSource = self
        
        
        
        cell?.account.text = note.account
        cell?.textView.text = note.message
        cell?.date.text = note.date
        if let account = note.account {
            cell?.photo.image = loadImage(fileName: "\(account).jpg")
        }

        cell?.heartImageBtn.tag = indexPath.section * 10
        cell?.heartImageBtn.addTarget(self, action: #selector(heartBtnPressed), for: .touchDown)
        
        cell?.heartCount.setTitle("\(note.heartCount)塊巧克力", for: .normal)
        cell?.heartCount.tag = indexPath.section
    
        cell?.messageCount.setTitle("\(note.commentCount)則留言", for: .normal)
        cell?.messageCount.tag = indexPath.section
        cell?.messageBtn.tag = indexPath.section
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        print("\(indexPath.section), \(indexPath.row)")
        if indexPath.section > 0 {
            let lightbox = self.lightboxImages[indexPath.section - 1]
            lightboxController = LightboxController(images: lightbox, startIndex: 0)
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        if segue.identifier == "fullSegue"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let note = self.data[indexPath.section - 1]
                let fullVC = segue.destination as! FullViewController
                fullVC.currentData = note
//                fullVC.currentImage = image(fileName: note.imageName)
            }
        }
 
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

    @objc func heartBtnPressed(sender:UIButton ) {
        
        
        let indexPath = (sender.tag) / 10
        let note = self.data[indexPath - 1]
        guard let paperName = note.paperName else { return}
        guard let account = UserDefaults.standard.string(forKey: "account") else { return}
        let databasePaperName = self.databaseRef.child("Paper").child(paperName)
        let heart: [String : Any] = ["postTime": [".sv":"timestamp"],"account" : account,"uid" : self.uid!]
        
        databasePaperName.child("heart").child(self.uid!).setValue(heart)
        { (error, database) in
            if let error = error {
                assertionFailure("Fail To postMessage \(error)")
            }
            print("上傳巧克力成功")
        }
        self.tableView.reloadData()
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
    
    func didPostMessage(note: DatabaseData) {
        print("didPostMessage")
    }
    
}


extension HomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.data[section].imageName.count)
        return self.data[section].imageName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        let note = self.data[indexPath.item - 1].imageName[indexPath.item]
        print(note)
        cell.photoView.image = loadImage(fileName: "\(note).jpg")
        return cell
    }
}

