//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 8/24/17.
//  Copyright © 2017 Markus Staas (Lazada eLogistics Group). All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var coreData = CoreDataConnection.sharedInstance

  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let mapPress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation(_:)))
        mapPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(mapPress)
        getCoordsFromDB()
    }
    func getCoordsFromDB(){
        let myData = itemsFromCoreData
        let ct = myData.count
        print(ct)
        if ct > 0{
            for row in 0...ct-1{
                //for row in myData{
                let lat = myData[row].value(forKey: "lat")
                let lon = myData[row].value(forKey: "long")
                let annotation = MKPointAnnotation()
                annotation.title = "This is the title"
                annotation.subtitle = "this is the subtitle"
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat as! Double, longitude: lon as! Double)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addAnnotation(_ recognizer: UIGestureRecognizer){
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let newCoordinates : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        let annotationPlus = MKPointAnnotation()
        annotationPlus.coordinate = newCoordinates
        
        if recognizer.state == .began{
            self.mapView.addAnnotation(annotationPlus)
        }
        if recognizer.state == .ended{
            //write coords to Pin entity
            let pinLat = newCoordinates.latitude
            let pinLong = newCoordinates.longitude
            saveToCoreData(longitude: pinLong, latitude: pinLat)
        }

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            return nil
        }

        let identifier = "pinAnnotation"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = annotation
            
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: identifier)
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = btn

            return annotationView
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print("Button taaped ")
           performSegue(withIdentifier: "FlickrView", sender: self)
        }
    }
    
    //This is will automatically get the latest list from the database.
    var itemsFromCoreData: [NSManagedObject] {
        
        get {
            var resultArray:Array<NSManagedObject>!
            let managedContext = coreData.persistentContainer.viewContext
            //2
            let fetchRequest =
                NSFetchRequest<NSManagedObject>(entityName: CoreDataConnection.kItem)
            fetchRequest.returnsObjectsAsFaults = false
            //3
            do {
                resultArray = try managedContext.fetch(fetchRequest)

            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            return resultArray
        }
        
    }
    
    func saveToCoreData(longitude: Double, latitude: Double){
        let item = coreData.createManagedObject(entityName: CoreDataConnection.kItem) as! Pin
        item.lat = latitude
        item.long = longitude
        coreData.saveDatabase { (success) in
            if (success){
            }
            
        }
        
    }
    
}




