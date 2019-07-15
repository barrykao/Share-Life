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
    
    var databaseRef : DatabaseReference!
    
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let alert = UIAlertController(title: "注意!!", message: "提醒您：請輸入正確的E-mail格式。\n忘記密碼時，將寄送驗證信件至信箱，以便修改密碼。\n暱稱無法更改", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func SignUp(_ sender: Any) {
        
        guard self.newAccount.text != "" && self.newPassword.text != "" && self.nickName.text != "" else {
            isEmpty(controller: self)
            return
        }
        
        Auth.auth().createUser(withEmail: newAccount.text!, password: newPassword.text!) { (user, error) in
            if error == nil {
                print("You have successfully signed up")
                let alert = UIAlertController(title: "註冊", message: "註冊成功!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (ok) in
                    
                    self.delegate?.didFinishRegister(account: self.newAccount.text, password: self.newPassword.text, nickName: self.nickName.text)
                    
                    let uid = Auth.auth().currentUser!.uid
                    let accoutdict = ["account":self.newAccount.text!, "nickName": self.nickName.text!]
                    
                    self.databaseRef.child("User").child("\(uid)").setValue(accoutdict)
                    
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

