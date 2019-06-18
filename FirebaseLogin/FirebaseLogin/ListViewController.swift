//
//  ListViewController.swift
//  FirebaseLogin
//
//  Created by Michael on 2019/6/18.
//  Copyright © 2019 Zencher. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var fireUploadDic: [String:Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let databaseRef = Database.database().reference().child("ImageFireUpload")
        
        databaseRef.observe(.value, with: { [weak self] (snapshot) in
            
            if let uploadDataDic = snapshot.value as? [String:Any] {
                
                self?.fireUploadDic = uploadDataDic
                self?.tableView!.reloadData()
            }
        })

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

extension ListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataDic = fireUploadDic {
            print(dataDic.count)
            return dataDic.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.imageView!.image = UIImage(named:"loading")
        if let dataDic = fireUploadDic {
            let keyArray = Array(dataDic.keys)
            if let imageUrlString = dataDic[keyArray[indexPath.row]] as? String {
                print("***** imageUrlString: ", imageUrlString)
                if let imageUrl = URL(string: imageUrlString) {
                    URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        } else if let imageData = data {
                            DispatchQueue.main.async {
                                cell.imageView!.image = UIImage(data: imageData)
                                print("place a photo")
                            }
                        }
                    }).resume()
                }
            }
        }
        return cell

    }
    
    
}
