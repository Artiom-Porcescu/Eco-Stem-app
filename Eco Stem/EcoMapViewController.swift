//
//  EcoMapViewController.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 05.06.2023.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class EcoMapViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ecoMapButton: UITabBarItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var addView: UIView!
    @IBOutlet weak var ecoURLImageView: UIImageView!
    @IBOutlet weak var daggerButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    let regionInMeters: Double = 10000
    var selectedAnnotation: MKPointAnnotation?
    var pickerMark: UIImagePickerController?
    var pickerPlus: UIImagePickerController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationButton.setTitle("", for: .normal)
        refreshButton.setTitle("", for: .normal)
        plusButton.setTitle("", for: .normal)
        
        checkLocationServices()
        locationManager.delegate = self
        mapView.delegate = self
        addView.layer.cornerRadius = 5
        
        let db = Firestore.firestore()
        
        db.collection("locations").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let coords = document.get("pinLocation") {
                        let point = coords as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    func animateIn() {
        daggerButton.setTitle("", for: .normal)
        self.view.addSubview(addView)
        addView.center = self.view.center
        
        addView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.addView.alpha = 1
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3) {
            self.addView.alpha = 0
        } completion: { (success:Bool) in
            self.addView.removeFromSuperview()
        }
    }
    

    @IBAction func daggerPressed(_ sender: UIButton) {
        animateOut()
    }
    
    
    @IBAction func markAsDonePressed(_ sender: UIButton) {
        pickerMark = UIImagePickerController()
        pickerMark!.sourceType = .camera
        pickerMark!.delegate = self
        present(pickerMark!, animated: true)
    }
    
    @IBAction func reportPressed(_ sender: UIButton) {
        let storage = Storage.storage().reference()
        guard let reportedImage = ecoURLImageView.image?.jpegData(compressionQuality: 0.3) else { return }
        
        let imageString = NSUUID().uuidString
            
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
            
            storage.child("reported/\(imageString).jpg").putData(reportedImage, metadata: metaData) { (StorageMetadata, error) in
            guard StorageMetadata != nil else{
                print("oops an error occured while data uploading")
                return
            }
                 print("Image sent")
            }
        
        let alert = UIAlertController(title: "Great", message: "Thank you for your report, out team will check this content", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            print("No data")
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        default:
            print("Critical error")
        }
    }
    
    
    @IBAction func plusPressed(_ sender: UIButton) {
        pickerPlus = UIImagePickerController()
        pickerPlus!.sourceType = .camera
        pickerPlus!.delegate = self
        present(pickerPlus!, animated: true)
    }
    
    
    @IBAction func refreshPressed(_ sender: UIButton) {
        let db = Firestore.firestore()
        
        db.collection("locations").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let coords = document.get("pinLocation") {
                        let point = coords as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    
    @IBAction func userLocationPressed(_ sender: UIButton) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension EcoMapViewController: MKMapViewDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if picker == pickerPlus {
            guard let ecoImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            guard let currentLocation = locationManager.location else { return }
            
            let db = Firestore.firestore()
            let doc = db.collection("locations").document()

            let ecoPin = GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)

            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let time = Date().timeIntervalSince1970
            
            let date = Date(timeIntervalSince1970: time)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM-dd-yyyy HH:mm:ss"
            dateFormatter.timeZone = TimeZone.current
            
            let timeData = dateFormatter.string(from: date)
            
            let storage = Storage.storage().reference()
            guard  let imageData = ecoImage.jpegData(compressionQuality: 0.75) else {
                return
            }
            
            storage.child("pins/\(uid)").listAll { (res, err) in
                if let error = err {
                    print(error.localizedDescription)
                }
                for item in res!.items {
                    print(item)
                }
            }
            
            
                
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            
            let imageTime = NSUUID().uuidString
                
                storage.child("pins/\(imageTime)").putData(imageData, metadata: metaData) { (meta, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        storage.child("pins/\(imageTime)").downloadURL { (url, err) in
                            if let e = err {
                                print(e.localizedDescription)
                            } else {
                                let urlString = url?.absoluteString
                                doc.setData(["uid": uid, "pinLocation": ecoPin, "time": timeData, "url": urlString!]) { (error) in
                                    if error != nil {
                                        print(error?.localizedDescription)
                                        return
                                    } else {
                                        print("Saved")
                                    }
                                }
                            }
                        }
                    }
                     print("Image sent")
                }
        } else if picker == pickerMark {
            guard let markImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            let storage = Storage.storage().reference()
            guard  let imageDataMark = markImage.jpegData(compressionQuality: 0.75) else {
                return
            }
            
            let imageUid = NSUUID().uuidString
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
                
                storage.child("done/\(imageUid).jpg").putData(imageDataMark, metadata: metaData) { (StorageMetadata, error) in
                guard StorageMetadata != nil else{
                    print("oops an error occured while data uploading")
                    return
                }
                     print("Image sent")
                }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.tintColor = UIColor.systemGreen
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var coord = self.selectedAnnotation
        coord = view.annotation as? MKPointAnnotation
        let codeLat = coord?.coordinate.latitude
        let codeLon = coord?.coordinate.longitude
        
        let db = Firestore.firestore()
        
        db.collection("locations").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let coords = document.get("pinLocation") {
                        let point = coords as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        if codeLat == lat && codeLon == lon {
                            let imageUrl = document.data()["url"]
                            print(imageUrl!)
                            let er = "not found"
                            let url = URL(string: "\(imageUrl ?? er)")!
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: url) {
                                    DispatchQueue.main.async {
                                        self.ecoURLImageView.image = UIImage(data: data)
                                        self.ecoURLImageView.layer.cornerRadius = 10
                                        self.ecoURLImageView.clipsToBounds = true
                                        self.ecoURLImageView.layer.borderColor = UIColor.systemGreen.cgColor
                                        self.ecoURLImageView.layer.borderWidth = 3
                                        self.animateIn()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }

}
