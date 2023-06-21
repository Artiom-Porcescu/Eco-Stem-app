//
//  ViewController.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 05.06.2023.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.backgroundColor = .clear
        logInButton.layer.cornerRadius = 25
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.systemGreen.cgColor
        logInButton.clipsToBounds = true
        
        signUpButton.layer.cornerRadius = 25
        signUpButton.clipsToBounds = true
    }


}

