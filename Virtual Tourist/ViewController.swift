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
    
    var editMode:Bool = false
    var pins = [Pin]()
    var pinLat: Double = 0.0
    var pinLong: Double = 0.0
    var sharedContext : NSManagedObjectContext{
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
   
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let mapPress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation(_:)))
        mapPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(mapPress)
        showSavedPins()
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

    func getPinsFromDB() -> [Pin]{
        let fetchRequest=NSFetchRequest<Pin>(entityName:"Pin")
        do {
            return try sharedContext.fetch(fetchRequest)
        }catch{
            print("Could not fetch Pins")
            return [Pin]()
        }
    }
    
    func showSavedPins(){
        pins = getPinsFromDB()
        for pin in pins{
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
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
            let newPin = Pin(lat: annotationPlus.coordinate.latitude, long: annotationPlus.coordinate.longitude, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            pins.append(newPin)
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
            return annotationView
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        if editMode{
            for pin in pins{
                if view.annotation?.coordinate.latitude == pin.lat && view.annotation?.coordinate.longitude == pin.long{
                    sharedContext.delete(pin)
                    self.mapView.removeAnnotation(view.annotation!)
                    CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }else{
        
        //print(view.annotation?.coordinate.latitude)
            pinLat = view.annotation?.coordinate.latitude as Double!
            pinLong = view.annotation?.coordinate.longitude as Double!
        performSegue(withIdentifier: "FlickrView", sender: self)
        
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FlickrView") {
            let viewController = segue.destination as! FlickrCollectionViewController
            viewController.flickrLat = pinLat
            viewController.flickrLong = pinLong
        }
    }
    
}



