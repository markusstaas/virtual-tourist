//
//  FlickrConvinienceFunctions.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/13/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient {
    
    // Initiates a download from Flickr
    func downloadPhotosForPin(_ pin: Pin, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        var randomPageNumber: Int = 1
        
        if let numberPages = pin.pageNumber.intValue {
            if numberPages > 0 {
                let pageLimit = min(numberPages, 20)
                randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1 }
        }
        
        // Parameters for request photos
        let parameters: [String : AnyObject] = [
            FlickrAPI.FlickrParameterKeys.Method : FlickrAPI.Methods.Search as AnyObject,
            FlickrAPI.FlickrParameterKeys.APIKey : FlickrAPI.Constants.APIKey as AnyObject,
            FlickrAPI.FlickrParameterKeys.Format : FlickrAPI.FlickrParameterValues.JSONFormat as AnyObject,
            FlickrAPI.FlickrParameterKeys.NoJSONCallback : 1 as AnyObject,
            FlickrAPI.FlickrParameterKeys.Latitude : pin.lat as AnyObject,
            FlickrAPI.FlickrParameterKeys.Longitude : pin.long as AnyObject,
            FlickrAPI.FlickrParameterKeys.Extras : FlickrAPI.FlickrParameterValues.URLMediumPhoto as AnyObject,
            FlickrAPI.FlickrParameterKeys.Page : randomPageNumber as AnyObject,
            FlickrAPI.FlickrParameterKeys.PerPage : 21 as AnyObject
        ]
        
        // Make GET request for get photos for pin
        taskForGETMethodWithParameters(parameters, completionHandler: {
            results, error in
            
            if let error = error {
                completionHandler(false, error)
            } else {
                
                // Response dictionary
                if let photosDictionary = results?.value(forKey: FlickrAPI.FlickrResponseKeys.Photos) as? [String: AnyObject],
                    let photosArray = photosDictionary[FlickrAPI.FlickrResponseKeys.Photo] as? [[String : AnyObject]],
                    let numberOfPhotoPages = photosDictionary[FlickrAPI.FlickrResponseKeys.Pages] as? Int {
                    
                    pin.pageNumber = numberOfPhotoPages as NSNumber?
                    
                    self.numberOfPhotoDownloaded = photosArray.count
                    
                    // Dictionary with photos
                    for photoDictionary in photosArray {
                        
                        guard let photoURLString = photoDictionary[FlickrAPI.FlickrParameterValues.URLMediumPhoto] as? String else {
                            print ("error, photoDictionary)"); continue}
                        
                        // Create the Photos model
                        let newPhoto = Photos(photoURL: photoURLString, pin: pin, context: self.sharedContext)
                        
                        
                        // Download photo by url
                        self.downloadPhotoImage(newPhoto, completionHandler: {
                            success, error in
                            
                            //print("Downloading photo by URL - \(success): \(error)")
                            
                            self.numberOfPhotoDownloaded-=1
                            
                            // Posting NSNotifications
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "downloadPhotoImage.done"), object: nil)
                            
                            // Save the context
                            DispatchQueue.main.async(execute: {
                                CoreDataStackManager.sharedInstance().saveContext()
                            })
                        })
                    }
                    
                    completionHandler(true, nil)
                } else {
                    
                    completionHandler(false, NSError(domain: "downloadPhotosForPin", code: 0, userInfo: nil))
                }
            }
        })
    }
    
    // Download save image and change file path for photo
    func downloadPhotoImage(_ photo: Photos, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let imageURLString = photo.photoURL
        
        // Make GET request for download photo by url
        taskForGETMethod(imageURLString!, completionHandler: {
            result, error in
            
            // If there is an error - set file path to error to show blank image
            if let error = error {
                print("Error from downloading images \(error.localizedDescription )")
                photo.photoPath = "error"
                completionHandler(false, error)
                
            } else {
                
                if let result = result {
                    
                    // Get file name and file url
                    let fileName = (imageURLString! as NSString).lastPathComponent
                    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let pathArray = [dirPath, fileName]
                    let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
                    //print(fileURL)
                    
                    // Save file
                    FileManager.default.createFile(atPath: fileURL.path, contents: result, attributes: nil)
                    
                    // Update the Photos model
                    photo.photoPath = fileURL.path
                    
                    completionHandler(true, nil)
                }
            }
        })
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
}
