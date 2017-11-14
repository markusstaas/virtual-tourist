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
        print(pin!)
        let fetchRequest = NSFetchRequest<Photos>(entityName: "Photos")
        let photoContext = sharedContext
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoURL", ascending: true)]
       
       
        let fetchrc = NSFetchedResultsController<Photos>(fetchRequest: fetchRequest, managedObjectContext: photoContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = fetchrc
        
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
    reloadAll()
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
        
        if isDeleting == true
        {
          for indexPath in selectedPic {
                
                let photo = fetchedResultsController.object(at: indexPath)
                
                sharedContext.delete(photo)
                
            }
           selectedPic.removeAll()
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            reFetch()
            collectionView.reloadData()
            newCollectionButton.setTitle("New Collection", for: UIControlState())
            isDeleting = false
        } else {
            reloadAll()
        }
        
        
    }
    
    func reloadAll(){
        
        for photo in fetchedResultsController.fetchedObjects! {
            sharedContext.delete(photo)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
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
            DispatchQueue.main.async(execute: {
                self.reFetch()
                self.collectionView.reloadData()
            })
            
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    
            
            let cell = collectionView.cellForItem(at: indexPath) as! FlickrViewCell
            
            if let index = selectedPic.index(of: indexPath){
                selectedPic.remove(at: index)
                cell.deleteButton.isHidden = true
            } else {
                selectedPic.append(indexPath)
                cell.deleteButton.isHidden = false
                newCollectionButton.setTitle("New Collection", for: UIControlState())
            }
            
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrViewCell", for: indexPath) as! FlickrViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        
        cell.photoView.image = photo.image
        
        cell.deleteButton.isHidden = true
        cell.deleteButton.layer.setValue(indexPath, forKey: "indexPath")
        
        cell.deleteButton.addTarget(self, action: #selector(FlickrViewController.deletePhoto(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func deletePhoto(_ sender: UIButton){
        
        let photoIndex = sender.layer.value(forKey: "indexPath") as! IndexPath
        
        let photo = fetchedResultsController.object(at: photoIndex)
        
        if let index = selectedPic.index(of: photoIndex){
            selectedPic.remove(at: index)
        }
        sharedContext.delete(photo)
        CoreDataStackManager.sharedInstance().saveContext()
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

    
    
    


