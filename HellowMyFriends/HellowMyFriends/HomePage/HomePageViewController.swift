


import UIKit
import Firebase
import FirebaseAuth




class HomePageViewController: UIViewController ,UITableViewDataSource {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var photo: UIImageView!
    
    var data : [String?] = []
    
   
    
    
    var databaseRef : DatabaseReference!
    var paper : [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        let account = UserDefaults.standard.string(forKey: "account")
        let imageName = "\(account!).jpg"
        photo.image = image(fileName: imageName)
        loadFromFile()
        print(data)
    }
    
    //MARK:  UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataDic = paper {
            print(dataDic.count)
            return dataDic.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellTableViewCell
        
//        if let paperName = UserDefaults.standard.string(forKey: "paperName") {
//            print(paperName)
//            let fileName = "\(paperName).jpg"
//            if checkFile(fileName: fileName){
//                cell.photoview.image = image(fileName: fileName)
//            }else{
//                let databaseRef = Database.database().reference()
//                databaseRef.child(paperName).observe(.value) { (snapshot) in
//                    if let urlString = snapshot.value as? String {
//                        if let url = URL(string: urlString) {
//                            let request = URLRequest(url: url)
//                            let session = URLSession.shared
//                            let task = session.dataTask(with: request) { (data, response, error) in
//                                if let e = error {
//                                    print("error \(e)")
//                                }
//                                if let imageData = data {
//                                    DispatchQueue.main.async {
//                                        cell.photoview.image = thumbmailImage(image: UIImage(data: imageData)!, fileName: fileName)
//                                    }
//                                }
//                            }
//                            task.resume()
//                        }
//                    }
//                }
//            }
//        }
//        cell.photo.image
//        cell.textView.text
//        cell.date.text
//
        return cell
    }
  
    
    
    func loadFromFile() {
        
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("notes.archive")
        do{
            //把檔案轉成Data型式
            let fileData = try Data(contentsOf: fileURL)
            //從Data轉回Note陣列
            self.data = [String(data: fileData, encoding: .utf8)]
        }
        catch{
            print("error \(error)")
        }
    }
}
