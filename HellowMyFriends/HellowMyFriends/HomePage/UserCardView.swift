import UIKit

class UserCardView: UIView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet var photo: UIImageView!
    
    @IBOutlet var nickName: UILabel!
    
    @IBOutlet var profile: UILabel!
    
    @IBOutlet var topView: UIView!
    
    @IBOutlet var bottomView: UIView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // we're going to do stuff here.
        Bundle.main.loadNibNamed("UserCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.backgroundColor = UIColor.lightGray
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
}
