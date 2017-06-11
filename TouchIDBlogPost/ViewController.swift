//
//  ViewController.swift
//  TouchID


import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var enrollTouchIdSwitch: UISwitch!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    
    override func viewDidLoad() {
        super.viewDidLoad()

        let preferences = UserDefaults.standard
        var isTouchIDEnrolled:Bool! = false
        
        if preferences.object(forKey: "EnrollTouchID") != nil {
            isTouchIDEnrolled = preferences.object(forKey: "EnrollTouchID") as! Bool
            print(isTouchIDEnrolled)
        }
        
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
        
        //(x = nil) ? x : y
        // Check for empty fields
        if (userId.isEmpty || userPassword.isEmpty) {
            animateMe(textField: (userId.isEmpty ? self.userIdTextField : self.passwordTextField) )
            return
        }
        
        let preferences = UserDefaults.standard
        
        let rememberMe =  (rememberMeSwitch.isOn ? true : false)
        let enrollTouchId = (enrollTouchIdSwitch.isOn ? true : false)
        
        preferences.setValue(userId, forKey: "UserID")
        preferences.setValue(userPassword, forKey: "Password")
        preferences.setValue(rememberMe, forKey: "RememberMe")
        preferences.setValue(enrollTouchId, forKey: "EnrollTouchID")
        
        //print(preferences.object(forKey: "UserID"))
        //print(preferences.object(forKey: "Password"))
        //print(preferences.object(forKey: "RememberMe"))
        //print(preferences.object(forKey: "EnrollTouchID"))
        
    }
    
    func keyPadAuthenticateUser() {
        
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "RememberMe") != nil {
            let imRemembered = preferences.object(forKey: "RememberMe") as! Bool
            if (imRemembered) {
                userIdTextField.text = preferences.object(forKey: "UserID") as? String
                passwordTextField.text = preferences.object(forKey: "Password") as? String
                rememberMeSwitch.isOn = (preferences.object(forKey: "RememberMe") != nil)
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


    
    func touchAuthenticateUser() {
        let touchIDManager = PITouchIDManager()

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

                    // We show the alert view in the main thread (always update the UI in the main thread)
                    //OperationQueue.main.addOperation({ () -> Void in
                    //    self.showPasswordAlert()
                    //})
                case LAError.Code.touchIDNotEnrolled.rawValue:
                    print("TouchID not enrolled")
                    self.statusLabel.text = "TouchID not enrolled"
                case LAError.Code.passcodeNotSet.rawValue:
                    print("Passcode not set")
                    self.statusLabel.text = "Passcode not set"
                default:
                    print("Authentication failed")
                    self.keyPadAuthenticateUser()

                    //self.statusLabel.text = "Authentication failed"
                    //OperationQueue.main.addOperation({ () -> Void in
                    //    self.showPasswordAlert()
                    //})
                }
        })
    }

    func loadDada() {
        self.statusLabel.text = "Shifter authenticated"
    }

    func showPasswordAlert() {
        // New way to present an alert view using UIAlertController
        let alertController = UIAlertController(title:"702Shifter App",
                                                message: "Please enter password",
                                                preferredStyle: .alert)

        // We define the actions to add to the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print(action)
        }
        let doneAction = UIAlertAction(title: "Done", style: .default) { (action) -> Void in
            let passwordTextField = alertController.textFields![0] as UITextField
            if let text = passwordTextField.text {
                self.login(text)
            }
        }
        doneAction.isEnabled = false

        // We are customizing the text field using a configuration handler
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true

            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) -> Void in
                doneAction.isEnabled = textField.text != ""
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)

        self.present(alertController, animated: true) {
            // Nothing to do here
        }
    }

    func login(_ password: String) {
        if password == "prolific" {
            self.loadDada()
        } else {
            self.showPasswordAlert()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
}


