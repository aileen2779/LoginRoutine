import Foundation

class UserPreferences {

    private var _session: String!
    private var _userId: String!
    private var _password: String!
    private var _rememberMe: Bool!
    private var _enrollTouchId: Bool!

    let preferences = UserDefaults.standard
    
    var session: String {
        if preferences.object(forKey: "Session") != nil {
            _session = preferences.object(forKey: "Session") as! String
            return _session
        }
        return ""
    }
    
    var userId: String {
        if preferences.object(forKey: "UserID") != nil {
            _userId = preferences.object(forKey: "UserID") as! String
            return _userId
        }
        return ""
    }

    var password: String {
        if preferences.object(forKey: "Password") != nil {
            _password = preferences.object(forKey: "Password") as! String
            return _password
        }
        return ""
    }
    var rememberMe: Bool {
        if preferences.object(forKey: "EnrollTouchID") != nil {
            _enrollTouchId = preferences.object(forKey: "EnrollTouchID") as! Bool
            return _enrollTouchId
        }
        return false
    }
    
    var enrollTouchId: Bool {
        if preferences.object(forKey: "RememberMe") != nil {
            _rememberMe = preferences.object(forKey: "RememberMe") as! Bool
            return _rememberMe
        }
        return false
    }
    
    
    func setSession(key: String, value: String) {
        preferences.setValue(value, forKey: key)
        return
    }
    
}

