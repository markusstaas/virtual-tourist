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
    }
    
    func addAnnotation(_ recognizer: UIGestureRecognizer){
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let newCoordinates : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        if recognizer.state == .ended{
            //TO DO
            //write coords to Pin entity
            let pinLat = newCoordinates.latitude
            let pinLong = newCoordinates.longitude
            //print(newCoordinates.longitude)
            saveToCoreData(longitude: pinLong, latitude: pinLat)
        }
        self.mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            return nil
        }
        // TO DO
        //Get the pins from DB

        let identifier = "pinAnnotation"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: identifier)
            annotationView.isEnabled = true
            //annotationView.canShowCallout = true
            
            return annotationView
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
                //self.tableView.reloadData()
                //print(itemsFromCoreData)
               let myData = itemsFromCoreData
               let ct = myData.count
               
                for row in 0...ct-1{
                    print("dfasdf")
                }
            }
            
        }
        
    }
    
}




