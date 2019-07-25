import UIKit
import Firebase
import FirebaseAuth

protocol RegisterViewControllerDelegate : class{
    func didFinishRegister(account:String?, password:String?, nickName: String?)
}

class RegisterViewController: UIViewController ,UITextFieldDelegate {
    
    
    @IBOutlet weak var newAccount: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet var nickName: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet var textView: UITextView!
    
    var databaseRef : DatabaseReference!
    var currentData: PaperData! = PaperData()
    
    weak var delegate : RegisterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newAccount.delegate = self
        self.newPassword.delegate = self
        databaseRef = Database.database().reference()
        
        buttonDesign(button: signUpBtn)
        buttonDesign(button: backBtn)
        
        textFieldClearMode(textField: newAccount)
        textFieldClearMode(textField: newPassword)
        textFieldClearMode(textField: nickName)
        
        let item =  UIBarButtonItem(image: UIImage(named: "return"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = item
        self.navigationItem.hidesBackButton = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alertAction(controller: self, title: "注意!!", message: "提醒您：暱稱無法更改。\n請輸入正確的E-mail格式。\n忘記密碼時，將寄送驗證信件至信箱，以便修改密碼。")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func SignUp(_ sender: Any) {
        
        if checkInternetFunction() == true {
            //write something to download
            print("true")
            guard self.newAccount.text != "" && self.newPassword.text != "" && self.nickName.text != "" else {
                alertAction(controller: self, title: "警告", message: "有空格尚未填寫")
                return
            }
            guard let account = newAccount.text else {return}
            guard let password = newPassword.text else {return}
            guard let nickName = nickName.text else {return}
            let message = "帳號：\(account)\n密碼：\(password)\n暱稱：\(nickName)\n請確認資料是否正確"
            let controller = UIAlertController(title: "註冊", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                print("Yes")
                Auth.auth().createUser(withEmail: account, password: password) { (user, error) in
                    if error == nil {
                        print("You have successfully signed up")
                        let alert = UIAlertController(title: "註冊", message: "註冊成功", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (ok) in
                            self.currentData.account = account
                            self.currentData.nickName = password
                            //                    self.delegate?.didFinishRegister(account: self.newAccount.text, password: self.newPassword.text, nickName: self.nickName.text)
                            NotificationCenter.default.post(name: Notification.Name("AccountUpdated"), object: nil, userInfo: ["account": self.currentData!])
                            
                            let uid = Auth.auth().currentUser!.uid
                            let accoutdict = ["account":account,"uid":uid ,"nickName": nickName]
                            
                            self.databaseRef.child("User").child("\(uid)").setValue(accoutdict)
                            self.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        alertAction(controller: self, title: "錯誤", message: "帳號或密碼重複或是錯誤")
                    }
                }
            }
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "No", style: .destructive , handler: nil)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else {
            //error handling when no internet
            print("false")
            alertAction(controller: self, title: "連線中斷", message: "請確認您的網路連線是否正常，謝謝")
        }
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

