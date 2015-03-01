import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = NSUserDefaults.standardUserDefaults()
        
        if let username = settings.stringForKey("username") {
            usernameTextField.text = username
        }
        
        if let password = settings.stringForKey("password") {
            passwordTextField.text = password
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let settings = NSUserDefaults.standardUserDefaults()
        settings.setObject(usernameTextField.text, forKey: "username")
        settings.setObject(passwordTextField.text, forKey: "password")
    }
}