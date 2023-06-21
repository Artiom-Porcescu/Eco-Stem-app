//
//  MapBarViewController.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 05.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class MapBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

}
