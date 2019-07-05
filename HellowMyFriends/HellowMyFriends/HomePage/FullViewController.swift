//
//  FullViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/5.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class FullViewController: UIViewController {

    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var messageCount: UIButton!
    
    @IBOutlet var heartCount: UIButton!
    
    @IBOutlet var topView: UIView!
    
    @IBOutlet var downView: UIView!
    
    var currentImage: UIImage?
    var currentData: DatabaseData!
    var flag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        imageView.image = currentImage
        topView.isHidden = true
        downView.isHidden = true
        
        let singleFinger = UITapGestureRecognizer(
            target:self,
            action:#selector(tapSingleDid))
        
        // 點幾下才觸發 設置 2 時 則是要點兩下才會觸發 依此類推
        singleFinger.numberOfTapsRequired = 1
        
        // 幾根指頭觸發
        singleFinger.numberOfTouchesRequired = 1
        
        // 雙指輕點沒有觸發時 才會檢測此手勢 以免手勢被蓋過
//        singleFinger.requireGestureRecognizerToFail(doubleFingers)
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(singleFinger)
        
        // dismiss fullScreen
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(backBtn(_:)))
        swipeUp.direction = .up
        // 幾根指頭觸發 預設為 1
        swipeUp.numberOfTouchesRequired = 1
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeUp)        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        messageCount.setTitle("\(currentData.commentCount)則留言", for: .normal)
        heartCount.setTitle("\(currentData.heartCount)顆愛心", for: .normal)
        
    }
    
    
    @objc func tapSingleDid(_ ges:UITapGestureRecognizer){
        //显示或隐藏导航栏
        flag = !flag
        if flag {
            topView.isHidden = false
            downView.isHidden = false
        }else {
            topView.isHidden = true
            downView.isHidden = true
        }
    }
    
    @objc func tapDoubleDid(_ ges:UITapGestureRecognizer){
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "messageSegue" {
            let note = self.currentData
            let navigationVC = segue.destination as! UINavigationController
            let messageVC = navigationVC.topViewController as! MessageViewController
            messageVC.messageData = note
        }
        
        if segue.identifier == "heartSeuge" {
            
            
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
