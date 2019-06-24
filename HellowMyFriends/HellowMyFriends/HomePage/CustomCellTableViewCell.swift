//
//  CustomCellTableViewCell.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/18.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet var photoView: UIImageView!
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        
//        
//        
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    
    
    

}
