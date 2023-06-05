//
//  ProfileViewController.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 05.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageDB: UIImageView!
    @IBOutlet weak var profileNameDB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage().reference()
        guard let uid = Auth.auth().currentUser?.uid else { return }

        storage.child("users/\(uid).jpg").getData(maxSize: 1024 * 1024 * 1) { (data, error) in
            if error != nil {
                print("error occured")
                return
            } else {
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    self.profileImageDB.image = image
                }
            }
            
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { (documentsF, error) in
            if let err = error {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in documentsF!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let data = document.data()["username"]
                            self.profileNameDB.text = data as? String
                        }
                    }
        }
        profileImageDB.layer.cornerRadius = profileImageDB.bounds.height / 2
        profileImageDB.clipsToBounds = true
    }

}
