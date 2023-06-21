//
//  ForgotPasswordViewController.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 05.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.backgroundColor = .clear
        emailField.layer.cornerRadius = 27
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.systemGreen.cgColor
    }


    @IBAction func sendButtonPressed(_ sender: UIButton) {
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: emailField.text!) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Oops", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Great", message: "A password reset email has been sent", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }


}
