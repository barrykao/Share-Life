


import UIKit
import Firebase
import FirebaseAuth
import CoreData

class HomePageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate ,PostMessageViewControllerDelegate {
    func didPostMessage(data: DatabaseData) {
        print("didPostMessage")
    }
    

    @IBOutlet weak var tableView: UITableView!

    
    
    var data : [DatabaseData] = []
    var dataSource = [[String:Any]()]

    var databaseRef : DatabaseReference!
    var storageRef : StorageReference!
    var fireUploadDic: [String:Any]?
    var uid : String?
    var photoName : [String?] = []
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        self.queryFromCoreData()
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.uid = Auth.auth().currentUser?.uid
        
        let databaseRef = Database.database().reference().child("Paper")
        print(databaseRef)
        databaseRef.observe(.value, with: { [weak self] (snapshot) in
            
            if let uploadDataDic = snapshot.value as? [String:Any] {
                let dataDic = uploadDataDic
                let keyArray = Array(dataDic.keys)
                print(dataDic)
                print(keyArray)
                
                for i in 0 ..< keyArray.count {
                    let array = dataDic[keyArray[i]] as! [String:Any]
//                    let moc = CoreDataHelper.shared.managedObjectContext()
//                    let note = DatabaseData(context: moc)
                    let note = DatabaseData()
                    note.account = array["account"] as? String
                    note.message = array["message"] as? String
                    note.date = array["date"] as? String
                    note.url = array["photo"] as? String
                    note.uid = array["uid"] as? String
                    self?.data.append(note)
                }
            }
//            self?.saveToCoreData()
            self!.tableView.reloadData()
        })
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.data.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCellTableViewCell
        
        var cell: CustomCellTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "customCell") as? CustomCellTableViewCell
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCellTableViewCell
            //            cell = CustomCellTableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            cell?.textLabel?.text = "在想些什麼?"
            if let account = UserDefaults.standard.string(forKey: "account") {
                cell?.imageView?.image = checkImage(fileName: "\(account).jpg")
            }
            return cell!
        }
        
        
        let dict = self.data[indexPath.row - 1]
        
        cell?.account.text = dict.account
        cell?.textView.text = dict.message
        cell?.date.text = dict.date
        if let url = dict.url {
            if let url = URL(string: url){
                
                let request = URLRequest(url: url)
                let session = URLSession.shared
                let task = session.dataTask(with: request) { (data, response, error) in
                    
                    if let e = error {
                        print("error \(e)")
                    }
                    if let imageData = data {
                        DispatchQueue.main.async {
                         cell?.photoView.image = UIImage(data: imageData)
                        }
                    }
                }
                task.resume()
                
            }
        }
        if let uid = dict.uid {
            let databaseRef = Database.database().reference().child("User").child(uid).child("photo")
            databaseRef.observe(.value) { (snapshot) in
                if let url = snapshot.value as? String{
                    if let url = URL(string: url){
                        
                        let request = URLRequest(url: url)
                        let session = URLSession.shared
                        let task = session.dataTask(with: request) { (data, response, error) in
                            
                            if let e = error {
                                print("error \(e)")
                            }
                            if let imageData = data {
                                DispatchQueue.main.async {
                                    cell?.photo.image = UIImage(data: imageData)
                                }
                            }
                        }
                        task.resume()
                    }
            }
            }
        }
        return cell!
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "postSegue" {
//            if  let indexPath = self.tableView.indexPathForSelectedRow{
//                let note = self.data[indexPath.row] //找到使用者點擊的note物件
                let navigationController = segue.destination as! UINavigationController
                let postVC = navigationController.topViewController as! PostMessageViewController
//                postVC.currentName = note
                postVC.delegate = self
//            }
        }
        
        
        
        
    }
    
    /*
    func saveToCoreData () {
        CoreDataHelper.shared.saveContext()
    }
    
    func queryFromCoreData () {
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<DatabaseData>(entityName: "Database")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        moc.performAndWait {
            do{
                self.data = try moc.fetch(request)
            }catch{
                print("error \(error)")
                self.data = []
            }
        }
    }
    */
    
    /*
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCellTableViewCell
     
     var cell: CustomCellTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "customCell") as? CustomCellTableViewCell
     
     if indexPath.row == 0 {
     cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCellTableViewCell
     //            cell = CustomCellTableViewCell(style: .subtitle, reuseIdentifier: "Cell")
     cell?.textLabel?.text = "在想些什麼?"
     if let account = UserDefaults.standard.string(forKey: "account") {
     cell?.imageView?.image = checkImage(fileName: "\(account).jpg")
     }
     return cell!
     }
     
     let dict:Dictionary = dataSource[indexPath.row]
     print(dict.keys)
     let account = dict["account"] as? String
     cell?.textView.text = dict["message"] as? String
     cell?.account.text = account
     cell?.date.text = dict["date"] as? String
     if let uid = dict["uid"] as? String {
     let databaseRef = Database.database().reference().child("User").child(uid).child("photo")
     print(databaseRef)
     databaseRef.observe(.value) { (snapshot) in
     if let urlString = snapshot.value as? String {
     if let url = URL(string: urlString) {
     let request = URLRequest(url: url)
     let session = URLSession.shared
     let task = session.dataTask(with: request) { (data, response, error) in
     if let e = error {
     print("error \(e)")
     }
     if let imageData = data {
     DispatchQueue.main.async {
     cell?.photo.image = UIImage(data: imageData)
     }
     }
     }
     task.resume()
     }
     }
     }
     }
     
     
     if let urlPhoto = dict["photo"] as? String {
     if let url = URL(string: urlPhoto) {
     let request = URLRequest(url: url)
     let session = URLSession.shared
     let task = session.dataTask(with: request) { (data, response, error) in
     if let e = error {
     print("error \(e)")
     }
     if let imageData = data {
     DispatchQueue.main.async {
     cell?.photoView.image = UIImage(data: imageData)
     }
     }
     }
     task.resume()
     }
     }
     
     return cell!
     
     }
     */
}
