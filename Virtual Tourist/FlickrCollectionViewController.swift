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
    
    var flickrLat: Double = 0.0
    var flickrLong: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedPic = [IndexPath]()
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
     var fetchedResultsController:NSFetchedResultsController<Photos>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //let fetchRequest = NSFetchRequest<Photos>(entityName: "Photos")
       // let photoContext = sharedContext
       // let frc = NSFetchedResultsController<Photos>(fetchRequest: fetchRequest, managedObjectContext: photoContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //fetchedResultsController = frc
        
          mapView.delegate = self
        loadSelectedPinOnMapView()
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    
    func getImagesFromFlickr(){
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=df1c8e24162af5e93c1935e24018579a&lat=\(flickrLat)&lon=\(flickrLong)&extras=url_m&format=json&nojsoncallback=1"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if let data = data{
                    
                    let parsedResult: [String:AnyObject]!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    }catch{
                        print("Could not parse the data")
                        return
                    }
                    if let photosDictionary = parsedResult[FlickrAPI.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[FlickrAPI.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                        
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                       // let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
                        
                    }
                   print(parsedResult)
                }
            }
        }
        
        task.resume()

    }

    func loadSelectedPinOnMapView() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(flickrLat, flickrLong)
        mapView.centerCoordinate = annotation.coordinate
        mapView.addAnnotation(annotation)
    }
    

}
