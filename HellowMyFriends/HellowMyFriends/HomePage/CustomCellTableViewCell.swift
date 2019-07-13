//
//  CustomCellTableViewCell.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/18.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MessageTableViewCell: UITableViewCell {
    
    
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet var account: UILabel!
    
    @IBOutlet var message: UILabel!
    
}


class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
//    @IBOutlet weak var textView: UITextView!

    
    @IBOutlet var label: UILabel!
    
    
    @IBOutlet var heartCount: UIButton!

    @IBOutlet var messageCount: UIButton!
    
    @IBOutlet var heartImageBtn: UIButton!
    
    @IBOutlet var messageBtn: UIButton!

    @IBOutlet var photoCount: UIImageView!
    
    
    @IBOutlet var collectionView: UICollectionView!

    var currentData: DatabaseData!
    var collectionViewData: [DatabaseData] = []
    let fullScreenSize = UIScreen.main.bounds.size
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CustomCellTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentData.imageName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        
        let note = self.currentData.imageName[indexPath.row]
        
        cell.photoView.image = loadImage(fileName: "\(note).jpg")
        
        return cell
    }
    
    
}

extension CustomCellTableViewCell: UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return CGSize(width: (fullScreenSize.width - 16), height: fullScreenSize.height )
    
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
