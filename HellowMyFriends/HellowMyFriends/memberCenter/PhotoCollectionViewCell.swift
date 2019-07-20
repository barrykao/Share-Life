//
//  PhotoCollectionViewCell.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/25.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var picturesView: UIImageView!
    
    @IBOutlet var photoView: UIImageView!

}


class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!

}

class PostMessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
}

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photoView: UIImageView!
    
}

class EditCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photoView: UIImageView!
    
}
