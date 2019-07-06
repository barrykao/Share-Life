//
//  FullViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/5.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class FullViewController: UIViewController ,UIScrollViewDelegate{

    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var messageCount: UIButton!
    
    @IBOutlet var heartCount: UIButton!
    
    @IBOutlet var topView: UIView!
    
    @IBOutlet var downView: UIView!
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    
    
    var currentImage: UIImage?
    var currentData: DatabaseData!
    var flag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        imageView.image = currentImage
        topView.isHidden = true
        downView.isHidden = true
        
        imageView.tag = 999
        scrollView.contentSize = imageView.image!.size
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self

        // dismiss fullScreen
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(backBtn(_:)))

        swipeUp.direction = .up
        // 幾根指頭觸發 預設為 1
        swipeUp.numberOfTouchesRequired = 1
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeUp)

        
        let doubleFingers = UITapGestureRecognizer( target:self, action:#selector(tapDoubleDid))
        
        // 點幾下才觸發 設置 1 時 則是點一下會觸發 依此類推
        doubleFingers.numberOfTapsRequired = 2
        // 幾根指頭觸發
        doubleFingers.numberOfTouchesRequired = 1
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(doubleFingers)
        
        // 單指輕點
        let singleFinger = UITapGestureRecognizer( target:self, action:#selector(tapSingleDid))
        
        // 點幾下才觸發 設置 2 時 則是要點兩下才會觸發 依此類推
        singleFinger.numberOfTapsRequired = 1
        
        // 幾根指頭觸發
        singleFinger.numberOfTouchesRequired = 1
        
        // 雙指輕點沒有觸發時 才會檢測此手勢 以免手勢被蓋過
        singleFinger.require(toFail: doubleFingers)
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(singleFinger)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        messageCount.setTitle("\(currentData.commentCount)則留言", for: .normal)
        heartCount.setTitle("\(currentData.heartCount)塊巧克力", for: .normal)
        
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
        
        UIView.animate(withDuration: 0.5, animations: {
            //如果当前不缩放，则放大到3倍。否则就还原
            if self.scrollView.zoomScale == 1.0 {
                self.scrollView.zoomScale = 3.0
            }else{
                self.scrollView.zoomScale = 1.0
            }
        })
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //        return scrollView.subviews[0]
        return scrollView.viewWithTag(999)
    }
}
