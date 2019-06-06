import UIKit


class FirstViewController: UIViewController ,UITextFieldDelegate {
    
    var data : [userData] = []
    
    @IBOutlet weak var theAccount: UITextField!
    
    @IBOutlet weak var thePassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.theAccount.delegate = self
        self.thePassword.delegate = self
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func Clear(_ sender: Any) {
        self.theAccount.text = ""
        self.thePassword.text = ""
    }
    @IBAction func addNewAccount(_ sender: Any) {
        
        self.theAccount.text = ""
        self.thePassword.text = ""
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddSegue"{
            
            
            print("prepare")
        }
    }
    
    @IBAction func SignIn(_ sender: Any) {
      
        let str = userData()
        str.userAccount = self.theAccount.text
        str.userPassword = self.thePassword.text
    
    //MARK:
        guard str.userAccount?.isEmpty != true else{
            isEmpty(controller: self)
            return
        }
        guard str.userAccount!.count > 5 && str.userAccount!.count < 10 else {
            judge(controller: self)
            return
        }
        guard str.userPassword?.isEmpty != true else {
            isEmpty(controller: self)
            return
        }
        guard str.userPassword!.count > 5 && str.userPassword!.count < 10 else {
            judge(controller: self)
            return
        }
    }
    
    
}
