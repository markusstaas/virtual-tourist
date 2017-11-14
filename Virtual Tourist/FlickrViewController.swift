//
//  FlickrViewController.swift
//  Virtual Tourist
//
//  Created by Markus Staas on 10/20/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    var pin: Pin? = nil
    var flickrLat: Double = 0.0
    var flickrLong: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedPic = [IndexPath]()
    var isDeleting = false
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var fetchedResultsController:NSFetchedResultsController<Photos>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<Photos>(entityName: "Photos")
        let photoContext = sharedContext
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: true)]
       
       
        let frc = NSFetchedResultsController<Photos>(fetchRequest: fetchRequest, managedObjectContext: photoContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = frc
        
        mapView.delegate = self
        loadSelectedPinOnMapView()
        collectionView.delegate = self
        collectionView.dataSource = self

        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("\(error)")
        }
        fetchedResultsController.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(FlickrViewController.photoReload(_:)), name: NSNotification.Name(rawValue: "downloadPhotoImage.done"), object: nil)
        }
    // Inserting dispatch_async to ensure the closure always run in the main thread
    func photoReload(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
            
        })
    }
    fileprivate func reFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("reFetch - \(error)")
        }
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        
        // If deleting flag is true, delete the photo
        if isDeleting == true
        {
            // Removing the photo that user selected one by one
            for indexPath in selectedPic {
                
                // Get photo associated with the indexPath.
                let photo = fetchedResultsController.object(at: indexPath)
                
                print("Deleting this -- \(photo)")
                
                // Remove the photo
                sharedContext.delete(photo)
                
            }
            // Empty the array of indexPath after deletion
           // selectedIndexofCollectionViewCells.removeAll()
            
            // Save the chanages to core data
            CoreDataStackManager.sharedInstance().saveContext()
            
            // Update cells
            reFetch()
            collectionView.reloadData()
            // Change the button to say 'New Collection' after deletion
            newCollectionButton.setTitle("New Collection", for: UIControlState())
            
            isDeleting = false
            
            // Else "New Collection" button is tapped
        } else {
            // 1. Empty the photo album from the previous set
            for photo in fetchedResultsController.fetchedObjects! {
                sharedContext.delete(photo)
            }
            
            // 2. Save the chanages to core data
            CoreDataStackManager.sharedInstance().saveContext()
            
            // 3. Download a new set of photos with the current pin
            FlickrClient.sharedInstance().downloadPhotosForPin(pin!, completionHandler: {
                success, error in
                
                if success {
                    DispatchQueue.main.async(execute: {
                        CoreDataStackManager.sharedInstance().saveContext()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        print("error downloading a new set of photos")
                       
                    })
                }
                // Update cells
                DispatchQueue.main.async(execute: {
                    self.reFetch()
                    self.collectionView.reloadData()
                })
                
            })
        }
        
        
    }
    
    // Return the number of photos from fetchedResultsController
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("Number of photos returned from fetchedResultsController #\(sectionInfo.numberOfObjects)")
        
        // If numberOfObjects is not zero, hide the noImagesLabel
       // noImagesLabel.isHidden = sectionInfo.numberOfObjects != 0
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    
            
            // Configure the UI of the collection item
            let cell = collectionView.cellForItem(at: indexPath) as! FlickrViewCell
            
            // When user deselect the cell, remove it from the selectedIndexofCollectionViewCells array
            if let index = selectedPic.index(of: indexPath){
                selectedPic.remove(at: index)
                cell.deleteButton.isHidden = true
            } else {
                // Else, add it to the selectedIndexofCollectionViewCells array
                selectedPic.append(indexPath)
                cell.deleteButton.isHidden = false
                newCollectionButton.setTitle("New Collection", for: UIControlState())
            }
            
            // If the selectedIndexofCollectionViewCells array is not empty, show the 'Delete # photo(s)' button
            if selectedPic.count > 0 {
                if selectedPic.count == 1{
                    newCollectionButton.setTitle("Delete \(selectedPic.count) photo", for: UIControlState())
                } else {
                    newCollectionButton.setTitle("Delete \(selectedPic.count) photos", for: UIControlState())
                }
                isDeleting = true
            } else{
                newCollectionButton.setTitle("New Collection", for: UIControlState())
                isDeleting = false
            }
            
        
        
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrViewCell", for: indexPath) as! FlickrViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        //print("Photo URL from the collection view is \(photo.url)")
        
        cell.photoView.image = photo.image
        
        cell.deleteButton.isHidden = true
        cell.deleteButton.layer.setValue(indexPath, forKey: "indexPath")
        
        // Trigger the action 'deletePhoto' when the button is tapped
        cell.deleteButton.addTarget(self, action: #selector(FlickrViewController.deletePhoto(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func deletePhoto(_ sender: UIButton){
        
        // I want to know if the cell is selected giving the indexPath
        let indexOfTheItem = sender.layer.value(forKey: "indexPath") as! IndexPath
        
        // Get the photo associated with the indexPath
        let photo = fetchedResultsController.object(at: indexOfTheItem)
        print("Delete cell selected from 'deletePhoto' is \(photo)")
        
        // When user deselected it, remove it from the selectedIndexofCollectionViewCells array
        if let index = selectedPic.index(of: indexOfTheItem){
            selectedPic.remove(at: index)
        }
        
        // Remove the photo
        sharedContext.delete(photo)
        
        // Save to core data
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Update selected cell
        reFetch()
        collectionView.reloadData()
    }
    
    
    func loadSelectedPinOnMapView() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(flickrLat, flickrLong)
        mapView.centerCoordinate = annotation.coordinate
        mapView.addAnnotation(annotation)
    }
}

    
    
    


