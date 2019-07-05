//
//  fullScreenViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/2.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class fullScreenViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    @IBOutlet var topView: UIView!
    
    @IBOutlet var downView: UIView!

    @IBOutlet var messageCount: UIButton!
    
    @IBOutlet var heartCount: UIButton!
    
    var fullScreenData: [DatabaseData]!
    
    var currentFullData: DatabaseData! = DatabaseData()
    var databaseRef : DatabaseReference!
    var storageRef: StorageReference!
    var index: Int!
    var currentImage: UIImage?
    var pageControl : UIPageControl!
    let fullScreenSize = UIScreen.main.bounds.size
    var flag: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.view.backgroundColor = UIColor.black
        topView.isHidden = true
        downView.isHidden = true
        
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)

        //设置页控制器
        pageControl = UIPageControl()
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        pageControl.numberOfPages = fullScreenData.count
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = index
        view.addSubview(self.pageControl)
        // tapSingle
       

        
        
        
        
        // dismiss fullScreen
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(backBtn(_:)))
        swipeUp.direction = .up
        // 幾根指頭觸發 預設為 1
        swipeUp.numberOfTouchesRequired = 1
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeUp)
      
    }
   

    override func viewDidAppear(_ animated: Bool) {
        
        let note = self.fullScreenData[self.index]
        messageCount.setTitle("\(note.commentCount)則留言", for: .normal)
        heartCount.setTitle("\(note.heartCount)顆愛心", for: .normal)

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //将视图滚动到当前图片上
        let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        //重新设置页控制器的位置
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        
    }
    
    @IBAction func editBtn(_ sender: Any) {
        
        print(sender)
        
        let controller = UIAlertController(title: "修改貼文", message: "請選擇操作功能", preferredStyle: .actionSheet)
        let names = ["編輯貼文", "刪除貼文"]
        for name in names {
            let action = UIAlertAction(title: name, style: .default) { (action) in
                if action.title == "編輯貼文" {
                    if let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "EditPostVC") as? UINavigationController
                    {
                        print("編輯貼文")
                        let current = self.fullScreenData[self.index]
                        let editPostVC = navigationVC.topViewController as! EditPostViewController
                        editPostVC.editData = current
                        editPostVC.editImage = image(fileName: current.imageName!)
                        self.present(navigationVC, animated: true, completion: nil)
                    }
                    
                }
                if action.title == "刪除貼文" {
                    print("刪除貼文")
                    // ....
                    let controller = UIAlertController(title: "刪除貼文", message: "請問是否確認刪除貼文", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                        print("Yes")
                        let current = self.fullScreenData[self.index]
                        guard let account = UserDefaults.standard.string(forKey: "account") else {return}
                        let storageRefAccount = self.storageRef.child("\(account).jpg")
                        storageRefAccount.child(current.imageName!).delete(completion: nil)
                        
                        let databaseRefPaper = self.databaseRef.child("Paper")
                        databaseRefPaper.child(current.paperName!).removeValue(completionBlock: { (error, data) in
                            
                            if checkFile(fileName: current.imageName!) {
                                let url = fileDocumentsPath(fileName: current.imageName!)
                                do{
                                    try FileManager.default.removeItem(at: url)
                                }catch{
                                    print("error: \(error)")
                                }
                            }
                        })
                        self.dismiss(animated: true)
                    }
                    controller.addAction(okAction)
                    //                    self.dismiss(animated: true)
                    let cancelAction = UIAlertAction(title: "No", style: .destructive , handler: nil)
                    controller.addAction(cancelAction)
                    self.present(controller, animated: true, completion: nil)
                }
            }
            controller.addAction(action)
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageSegue" {
            let note = self.fullScreenData[self.index]
            let navigationVC = segue.destination as! UINavigationController
            let messageVC = navigationVC.topViewController as! MessageViewController
            messageVC.messageData = note

        }
        
        if segue.identifier == "heartSegue" {
            let note = self.fullScreenData[self.index]
            let navigationVC = segue.destination as! UINavigationController
            let messageVC = navigationVC.topViewController as! HeartViewController
            messageVC.messageData = note
            
            
        }
        
    }
    
}

extension fullScreenViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fullScreenData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullCell", for: indexPath) as! PhotoCollectionViewCell
        let duc = fullScreenData[indexPath.item]
        cell.imageView.image = image(fileName: duc.imageName)
        
        return cell
    }
    
}


extension fullScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        flag = !flag
        if flag {
            topView.isHidden = false
            downView.isHidden = false
        }else {
            topView.isHidden = true
            downView.isHidden = true
        }
        self.index = indexPath.item

    }
    
    
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//    }
    
    //collectionView里某个cell显示完毕
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //当前显示的单元格
        let visibleCell = collectionView.visibleCells[0]
        //设置页控制器当前页
        self.pageControl.currentPage = collectionView.indexPath(for: visibleCell)!.item
        
        let note = self.fullScreenData[indexPath.item]
        messageCount.setTitle("\(note.commentCount)則留言", for: .normal)
        heartCount.setTitle("\(note.heartCount)顆愛心", for: .normal)
        topView.isHidden = true
        downView.isHidden = true
        
    }
}


extension fullScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return fullScreenSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
