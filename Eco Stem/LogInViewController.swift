//
//  LogInViewController.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 05.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.backgroundColor = .clear
        emailTextField.layer.cornerRadius = 25
        emailTextField.layer.borderWidth = 3
        emailTextField.layer.borderColor = UIColor.systemGreen.cgColor
        emailTextField.clipsToBounds = true
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.layer.cornerRadius = 25
        passwordTextField.layer.borderWidth = 3
        passwordTextField.layer.borderColor = UIColor.systemGreen.cgColor
        passwordTextField.clipsToBounds = true
        
        loginButton.layer.cornerRadius = 25
        loginButton.clipsToBounds = true
    }
    

    
    @IBAction func logInPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let alert = UIAlertController(title: "Oops", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self.performSegue(withIdentifier: "logInToMap", sender: self)
                }
            }
        }
    }
    
}
