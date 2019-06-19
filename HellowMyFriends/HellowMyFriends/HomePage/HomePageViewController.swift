


import UIKit
import Firebase
import FirebaseAuth




class HomePageViewController: UIViewController ,UITableViewDataSource {

    
    
    @IBOutlet weak var tableView: UITableView!
    
   
    @IBOutlet weak var photo: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        let account = UserDefaults.standard.string(forKey: "account")
        let imageName = "\(account!).jpg"
        photo.image = image(fileName: imageName)
        
        
    }
    
    //MARK:  UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }

    
 
    
}
