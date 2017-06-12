//
//  ViewController.swift
//  TouchID


import UIKit
import LocalAuthentication

class ViewController: UIViewController {


    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var logoutStackView: UIStackView!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var enrollTouchIdSwitch: UISwitch!
    
    // Define a class for user preferences
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var isTouchIDEnrolled:Bool! = false
        let enrollTouchId = preferences.object(forKey: "EnrollTouchID") as? Bool
        let rememberMe = preferences.object(forKey: "RememberMe") as? Bool
        let sessionId = preferences.object(forKey: "Session") as? String

        
        if enrollTouchId != nil {
            isTouchIDEnrolled = preferences.object(forKey: "EnrollTouchID") as! Bool
        }
        
        //check if my settings]
        if rememberMe != nil {
            if (rememberMe)! {
                self.restoreDefaults()
            }
        }

        // find out if user was previously logged on
        if sessionId != nil {
            self.loadDada()
            return
        }
        
        // not logged in
        if (isTouchIDEnrolled) {
            self.touchAuthenticateUser()
        } else {
            self.keyPadAuthenticateUser()
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {

        // evaluate login and password
        let userId          = userIdTextField.text!
        let userPassword    = passwordTextField.text!

        // Check for text fields then animate if empty
        if (userId.isEmpty || userPassword.isEmpty) {
            animateMe(textField: (userId.isEmpty ? self.userIdTextField : self.passwordTextField) )
            return
        }
        
        if (userId != "gamy316" && userPassword != "gamy666") {
            animateMe(textField: self.userIdTextField)
            animateMe(textField: self.passwordTextField)
            return
        }
        
        
        if (rememberMeSwitch.isOn ? true : false) == true {
            saveDefaults()
        } else {
            clearDefaults()
        }
 
        self.loadDada()
        
    }
    

    func loadDada() {
        // dismiss the keyboard
        self.view.endEditing(true)
        
        // set a new session
        preferences.setValue("123456", forKey: "Session")
        
        // hide the login stack view
        self.loginStackView.isHidden = true
        self.logoutStackView.isHidden = false

    }

    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

             // remove the session
             self.preferences.removeObject(forKey: "Session")
            
             // hide the log out stack view
             self.logoutStackView.isHidden = true
             
             // show the login stack view
             self.loginStackView.isHidden = false
             
             // set focus to the user id text field
             //self.userIdTextField.becomeFirstResponder()
 
        })
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
        

    }
    
    func keyPadAuthenticateUser() {

        loginStackView.isHidden = false
        
    }

    // this takes the saved values and stores them to the text fields
    func restoreDefaults() {
        userIdTextField.text = preferences.object(forKey: "UserID") as? String
        passwordTextField.text = preferences.object(forKey: "Password") as? String
        rememberMeSwitch.isOn = (preferences.object(forKey: "RememberMe") as? Bool)!
        enrollTouchIdSwitch.isOn = (preferences.object(forKey: "EnrollTouchID") as? Bool)!
    
    }
    
    
    func saveDefaults() {
        if (rememberMeSwitch.isOn)  {
            preferences.setValue(userIdTextField.text, forKey: "UserID")
            preferences.setValue(passwordTextField.text, forKey: "Password")
            preferences.setValue(rememberMeSwitch.isOn, forKey: "RememberMe")
            preferences.setValue(enrollTouchIdSwitch.isOn, forKey: "EnrollTouchID")
        }
    }
    
    func clearDefaults() {
        // only clear if rememberMeSwitch if off
        if !(rememberMeSwitch.isOn) {
            userIdTextField.text = ""
            passwordTextField.text = ""
            rememberMeSwitch.isOn = false
            enrollTouchIdSwitch.isOn = false
        }
    }
    
    func touchAuthenticateUser() {
        self.restoreDefaults()
        
        loginStackView.isHidden = false
        
        let touchIDManager = TouchIDManager()

        touchIDManager.authenticateUser(success: { () -> () in
            OperationQueue.main.addOperation({ () -> Void in
                self.loadDada()
            })
            }, failure: { (evaluationError: NSError) -> () in
                switch evaluationError.code {
                case LAError.Code.systemCancel.rawValue:
                    print("Authentication cancelled by the system")
                    self.keyPadAuthenticateUser()
                case LAError.Code.userCancel.rawValue:
                    print("Authentication cancelled by the user")
                    self.keyPadAuthenticateUser()
                case LAError.Code.userFallback.rawValue:
                    print("User wants to use a password")

                    self.keyPadAuthenticateUser()
                case LAError.Code.touchIDNotEnrolled.rawValue:
                    print("TouchID not enrolled")

                case LAError.Code.passcodeNotSet.rawValue:
                    print("Passcode not set")

                default:
                    print("Authentication failed")
                    self.keyPadAuthenticateUser()
                }
        })
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func animateMe(textField: UITextField) {
        let _thisTextField = textField
        var x = 0
        repeat {
            UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
            UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x -= 20 }, completion: nil)
            UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
            
            x += 1
        } while x < 3
    }

    
}


