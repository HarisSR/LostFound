//
//  LoginViewController.swift
//  LostFound
//
//  Created by Haris Shobaruddin Roabbni on 19/09/19.
//  Copyright © 2019 Haris Shobaruddin Robbani. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class LoginViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var loginTouched = false
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTouched = false
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            print("authorized1 ")
            if currentNetworkInfos?.first?.ssid == nil || currentNetworkInfos?.first?.ssid != "iosda-training" {
                let alert = UIAlertController(title: "Alert !", message: "You Can't Use this App Outside the Academy", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }else{
                print("authorized2")
                authentification()
            }
        } else {
            print("authorized3")
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
        
//        print(currentNetworkInfos?.first?.ssid!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
//    func updateWiFi() {
//        print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
//        ssidLabel.text = currentNetworkInfos?.first?.ssid
//        bssidLabel.text = currentNetworkInfos?.first?.bssid
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
//            updateWiFi()
            if currentNetworkInfos?.first?.ssid! == nil || currentNetworkInfos?.first?.ssid! != "iosda-training" {
                let alert = UIAlertController(title: "Alert !", message: "You Can't Use this App Outside the Academy", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }else{
                authentification()
            }
        }
    }
    
    func authentification(){
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                if self.loginTouched {
                    return
                }else{
                    let context = LAContext()
                    var error: NSError?
                    
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        let reason = "Identify yourself!"
                        
                        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                            [weak self] success, authenticationError in
                            
                            DispatchQueue.main.async {
                                if success {
                                    self!.performSegue(withIdentifier: "toItemList", sender: nil)
                                    self!.email.text = nil
                                    self!.password.text = nil
                                } else {
                                    let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                                    self!.present(ac, animated: true)
                                }
                            }
                        }
                    } else {
                        let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        }
    }
    
    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    @IBAction func loginDidTouch(_ sender: Any) {
        if currentNetworkInfos?.first?.ssid == nil || currentNetworkInfos?.first?.ssid != "iosda-training" {
            let alert = UIAlertController(title: "Alert !", message: "You Can't Use this App Outside the Academy", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }else{
            loginTouched = true
            guard
                let email = email.text,
                let password = password.text,
                email.count > 0,
                password.count > 0
                else {
                    return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                if let error = error, user == nil {
                    let alert = UIAlertController(title: "Sign In Failed",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.performSegue(withIdentifier: "toItemList", sender: nil)
                }
            }
        }
    }
    
    @IBAction func registerDidTouch(_ sender: Any) {
        if currentNetworkInfos?.first?.ssid == nil || currentNetworkInfos?.first?.ssid != "iosda-training" {
            let alert = UIAlertController(title: "Alert !", message: "You Can't Use this App Outside the Academy", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }else{
            let alert = UIAlertController(title: "Register",
                                          message: "Register",
                                          preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                let emailField = alert.textFields![0]
                let passwordField = alert.textFields![1]
                
                Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                    if error == nil {
                        Auth.auth().signIn(withEmail: self.email.text!,
                                           password: self.password.text!)
                    }else{
                        let alert = UIAlertController(title: "Registration Failed !", message: error!.localizedDescription, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        print("Error : ", error)
                    }
                }
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel)
            
            alert.addTextField { textEmail in
                textEmail.placeholder = "Enter your email"
            }
            
            alert.addTextField { textPassword in
                textPassword.isSecureTextEntry = true
                textPassword.placeholder = "Enter your password"
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}

public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false,
                                              ssid: nil,
                                              bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }
}

struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == email {
            password.becomeFirstResponder()
        }
        if textField == password {
            textField.resignFirstResponder()
        }
        return true
    }
}
