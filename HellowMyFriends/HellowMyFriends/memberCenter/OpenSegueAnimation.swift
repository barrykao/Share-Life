//
//  OpenSegueAnimation.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/7/7.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class OpenSegueAnimation: UIStoryboardSegue {
    
    override func perform() {
        // 取得來源端和目的端的視圖
        let VCAView = self.source.view as UIView? // 來源端(ViewController A)
        let VCBView = self.destination.view as UIView? // 目的端(ViewController B)
        
        // 取得畫面的寬度與高度
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // 生成上面和下面的View
        let upView = UIView()
        upView.backgroundColor = UIColor.red
        let downView = UIView()
        downView.backgroundColor = UIColor.blue
        
        // 設定目的端、左邊、右邊View的初始位置
        VCBView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        upView.frame = CGRect(x: 0, y: -(screenHeight / 2), width: screenWidth, height: screenHeight)
        downView.frame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight)
        
        // 取得App的key window並在來源端的View圖層上插入目的端、上面、下面的View
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(VCBView!, aboveSubview: VCAView!)
        window?.insertSubview(upView, aboveSubview: VCBView!)
        window?.insertSubview(downView, aboveSubview: VCBView!)
        
        // 轉場的動畫
        UIView.animate(withDuration: 0.7, animations: { () -> Void in
            upView.frame = upView.frame.offsetBy(dx:  0, dy: -screenHeight) // 上面視圖向上
            downView.frame = downView.frame.offsetBy(dx: 0, dy: screenHeight) // 下面視圖向下
        }) { (finish) -> Void in
            // 無動畫的方式呈現目的端的視圖
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
        }
    }
    
}
