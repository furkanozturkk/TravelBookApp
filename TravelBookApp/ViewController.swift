//
//  ViewController.swift
//  TravelBookApp
//
//  Created by Furkan Öztürk on 24.11.2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapkitView: MKMapView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var subTitleText: UITextField!
    var locationManager = CLLocationManager()
    var choosenLongitude = Double()
    var choosenLatitude = Double()
    
    var selectedTitle = ""
    var selectedId : UUID?
    
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapkitView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        navigationController?.navigationBar.topItem?.title = "TravelBookList"

        
        let gestureRecognizerKey = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                view.addGestureRecognizer(gestureRecognizerKey)
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapkitView.addGestureRecognizer(gestureRecognizer)
        
        if(selectedTitle != ""){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let idString = selectedId!.uuidString
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationsEntitiy")
            request.predicate = NSPredicate(format: "id = %@", idString)
            request.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "title") as? String {
                            annotationTitle = name
                            if let subTitle = result.value(forKey: "subtitle") as? String {
                                annotationSubTitle = subTitle
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubTitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapkitView.addAnnotation(annotation)
                                        titleText.text = annotationTitle
                                        subTitleText.text = annotationSubTitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapkitView.setRegion(region, animated: true)
                                        
                                        
                                    }
                                    
                                }
                            }
                        }
                        
                       
                        

                    }
                }
            }
            catch{
                Helper.Alert(title: "Hata...", message: "Kayıt Getirme İşlemi Sırasında Hata",hasReturn: true,over:self)
            }
        }
        else{
            
        }
    }
    
    @objc func hideKeyboard() {
         view.endEditing(true)
     }
    
    @IBAction func saveLocation(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "LocationsEntitiy", into: context)
        newLocation.setValue(titleText.text, forKey: "title")
        newLocation.setValue(subTitleText.text, forKey: "subtitle")
        newLocation.setValue(choosenLatitude, forKey: "latitude")
        newLocation.setValue(choosenLongitude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        if (titleText.text != "" && choosenLatitude != 0 && choosenLongitude != 0) {
            do{
                try context.save()
                Helper.Alert(title: "Başarılı...", message: "Kaydetme İşlemi Başarılı",hasReturn: true,over: self)
            }
            catch{
                Helper.Alert(title: "Hata...", message: "Kaydetme İşlemi Sırasında Hata",hasReturn: true,over:self)
            }
        }
        else{
            Helper.Alert(title: "Uyarı...", message: "Lütfen Tüm Alanların Dolu Olduğundan Emin Olunuz.",hasReturn: false,over:self)

        }
        
    }
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: self.mapkitView)
            let touchedCoordinate = mapkitView.convert(touchedPoint, toCoordinateFrom: self.mapkitView)
            
            choosenLatitude = touchedCoordinate.latitude
            choosenLongitude = touchedCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = titleText.text
            annotation.subtitle = subTitleText.text
            
            if(titleText.text != "" && subTitleText.text != ""){
                mapkitView.addAnnotation(annotation)
            }
            else{
                Helper.Alert(title: "Uyarı", message: "Önce Bir Başlık Giriniz.", hasReturn: false, over: self)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: location, span: span)
            mapkitView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if  annotation is MKUserLocation{
            return nil
        }

        let reusedId = "myAnnotation"
        var pinView = mapkitView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
        
        if(pinView == nil){
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView?.canShowCallout = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }
        else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item  = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        let launchOption = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOption)
                    }
                }
              
            }
        }
    }
    

}

