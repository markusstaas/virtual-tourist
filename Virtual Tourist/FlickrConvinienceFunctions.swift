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
    
    func downloadPhotosForPin(_ pin: Pin, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        var randomPageNumber: Int = 1
        
        if let numberPages = pin.pageNumber?.intValue {
            if numberPages > 0 {
                let pageLimit = min(numberPages, 20)
                randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1 }
        }
        
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
        
        taskForGETMethodWithParameters(parameters, completionHandler: {
            results, error in
            
            if let error = error {
                completionHandler(false, error)
            } else {
                
                if let photosDictionary = results?.value(forKey: FlickrAPI.FlickrResponseKeys.Photos) as? [String: AnyObject],
                    let photosArray = photosDictionary[FlickrAPI.FlickrResponseKeys.Photo] as? [[String : AnyObject]],
                    let numberOfPhotoPages = photosDictionary[FlickrAPI.FlickrResponseKeys.Pages] as? Int {
                    
                    pin.pageNumber = numberOfPhotoPages as NSNumber?
                    
                    for photoDictionary in photosArray {
                        
                        guard let photoURLString = photoDictionary[FlickrAPI.FlickrParameterValues.URLMediumPhoto] as? String else {
                            print ("error, photoDictionary)"); continue}
                        
                        let newPhoto = Photos(photoURL: photoURLString, pin: pin, context: self.sharedContext)
                        
                        self.downloadPhotoImage(newPhoto, completionHandler: {
                            success, error in
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "downloadPhotoImage.done"), object: nil)
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
func downloadPhotoImage(_ photo: Photos, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let imageURLString = photo.photoURL
        
        taskForGETMethod(imageURLString!, completionHandler: {
            result, error in
            
            if let error = error {
                print("Error from downloading images \(error.localizedDescription )")
                photo.photoPath = "error"
                completionHandler(false, error)
                
            } else {
                
                if let result = result {
                    
                    let fileName = (imageURLString! as NSString).lastPathComponent
                    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let pathArray = [dirPath, fileName]
                    let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
                    FileManager.default.createFile(atPath: fileURL.path, contents: result, attributes: nil)
                    
                    photo.photoPath = fileURL.path
                    
                    completionHandler(true, nil)
                }
            }
        })
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
}
