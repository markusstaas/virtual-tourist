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
    
    var coreData = CoreDataConnection.sharedInstance
    var editMode:Bool = false
    var selectedObjectID: NSManagedObjectID?
   
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        getCoordsFromDB()
        let mapPress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation(_:)))
        mapPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(mapPress)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if !editMode{
            editButton.title = "Done"
            editMode = true
            UIView.animate(withDuration: 0.7, animations: {
                self.view.frame.origin.y =  -45
                })
        }else{
            editButton.title = "Edit"
            editMode = false
            UIView.animate(withDuration: 0.7, animations: {
                self.view.frame.origin.y =  0
            })
        }
        
    }
    

    func getCoordsFromDB(){
        let myData = itemsFromCoreData
        let ct = myData.count

        if ct > 0{
            for row in 0...ct-1{
                //for row in myData{
                let lat = myData[row].value(forKey: "lat")
                let lon = myData[row].value(forKey: "long")
                let id = myData[row].objectID
                let annotation = MKPointAnnotation()
                annotation.title = "This is the title"
                annotation.subtitle = "this is the subtitle"
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat as! Double, longitude: lon as! Double)
                selectedObjectID = id
                mapView.addAnnotation(annotation)
                
            }
        }
    }
    
    func addAnnotation(_ recognizer: UIGestureRecognizer){
        let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
        let newCoordinates : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
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
           performSegue(withIdentifier: "FlickrView", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation
        //let item = itemsFromCoreData[1] as! Pin
        let item = view.annotation as! Pin
        //let test = item.managedObjectContext?.object(with: selectedObjectID!)
        //print("werwer \(test!)")
        //let item = itemsFromCoreData[1]
        coreData.deleteManagedObject(managedObject: item, completion: { (success) in
            if (success){
                print(annotation)
                mapView.removeAnnotation(annotation!)
                
            }else{
                print("the shit didnt work!!!")
            }
        })
        //let ObjectID =
            //deleteFromCoreData()
            
            //
      
    }
    
    //This is will automatically get the latest list from the database.
    var itemsFromCoreData: [NSManagedObject] {
        
        get {
            var resultArray:Array<NSManagedObject>!
            let managedContext = coreData.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataConnection.kItem)
            fetchRequest.returnsObjectsAsFaults = false
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
                print("Item added")
            }
            
        }
        
    }
    
    
}



