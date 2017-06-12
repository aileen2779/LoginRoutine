//
//  ViewController.swift
//  TouchID


import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var logoutStackView: UIStackView!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var enrollTouchIdSwitch: UISwitch!
    
    let preferences = UserDefaults.standard


    override func viewDidLoad() {
        super.viewDidLoad()

        var isTouchIDEnrolled:Bool! = false
        var isLoggedIn:Bool! = false
        
        if preferences.object(forKey: "EnrollTouchID") != nil {
            isTouchIDEnrolled = preferences.object(forKey: "EnrollTouchID") as! Bool
        }

        if preferences.object(forKey: "Session") != nil {
            isLoggedIn = true
            userIdTextField.text = preferences.object(forKey: "UserID") as? String
            passwordTextField.text = preferences.object(forKey: "Password") as? String
            rememberMeSwitch.isOn = (preferences.object(forKey: "RememberMe") as? Bool)!
            enrollTouchIdSwitch.isOn = (preferences.object(forKey: "EnrollTouchID") as? Bool)!
        }


        // if Logged in then no need to get authenticated
        if isLoggedIn {
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
        let userId = userIdTextField.text!
        let userPassword = passwordTextField.text!

        // Check for text fields then animate if empty
        if (userId.isEmpty || userPassword.isEmpty) {
            animateMe(textField: (userId.isEmpty ? self.userIdTextField : self.passwordTextField) )
            return
        }
        
        let rememberMe =  (rememberMeSwitch.isOn ? true : false)
        let enrollTouchId =  (enrollTouchIdSwitch.isOn ? true : false)
        
        if rememberMe {
            preferences.setValue(userIdTextField.text, forKey: "UserID")
            preferences.setValue(passwordTextField.text, forKey: "Password")
            preferences.setValue(rememberMe, forKey: "RememberMe")
            preferences.setValue(enrollTouchId, forKey: "EnrollTouchID")

        } else {
            userIdTextField.text = ""
            passwordTextField.text = ""
            rememberMeSwitch.isOn = false
            enrollTouchIdSwitch.isOn = false
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
        self.statusLabel.text = "Shifter authenticated"
        
    }

    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        
        // 2
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
             // remove the session
             self.preferences.removeObject(forKey: "Session")
             
             // set the text values to the user defaults
             self.preferences.setValue(self.userIdTextField.text, forKey: "UserID")
             self.preferences.setValue(self.passwordTextField.text, forKey: "Password")
             self.preferences.setValue(self.rememberMeSwitch.isOn, forKey: "RememberMe")
             self.preferences.setValue(self.enrollTouchIdSwitch.isOn, forKey: "EnrollTouchID")
             
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
        
        
        // 4
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        

    }
    
    func keyPadAuthenticateUser() {
        if preferences.object(forKey: "RememberMe") != nil {
            let imRemembered = preferences.object(forKey: "RememberMe") as! Bool
            if (imRemembered) {
                userIdTextField.text = preferences.object(forKey: "UserID") as? String
                passwordTextField.text = preferences.object(forKey: "Password") as? String
                rememberMeSwitch.isOn = preferences.object(forKey: "RememberMe") != nil
            }
        }

        if preferences.object(forKey: "EnrollTouchID") != nil {
            let touchIDEnrolled = preferences.object(forKey: "EnrollTouchID") as! Bool
            if (touchIDEnrolled) {
                enrollTouchIdSwitch.isOn = (preferences.object(forKey: "EnrollTouchID") != nil)
            }
        }
        loginStackView.isHidden = false
        
    }

    
    func touchAuthenticateUser() {
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
                    self.statusLabel.text = "User wants to use a password"
                    self.keyPadAuthenticateUser()
                case LAError.Code.touchIDNotEnrolled.rawValue:
                    print("TouchID not enrolled")
                    self.statusLabel.text = "TouchID not enrolled"
                case LAError.Code.passcodeNotSet.rawValue:
                    print("Passcode not set")
                    self.statusLabel.text = "Passcode not set"
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


