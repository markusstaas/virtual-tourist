//
//  FlickrHelper.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 10/23/17.
//  Copyright © 2017 Markus Staas . All rights reserved.


import UIKit

class FlickrHelper: NSObject {
    
    func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int) {
    
        // add the page to the method's parameters
        //var methodParametersWithPageNumber = methodParameters
        //methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        
        // create session and request
        let session = URLSession.shared
       // let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=df1c8e24162af5e93c1935e24018579a&lat=10.8231&lon=106.6297&extras=url_m&format=json&nojsoncallback=1"
        let url = URL(string: urlString)!
        // let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        let request = URLRequest(url: url)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                   // self.setUIEnabled(true)
                    //self.photoTitleLabel.text = "No photo returned. Try again."
                    //self.photoImageView.image = nil
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
               // let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                
                // if an image exists at the url, set the image and title
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    
                    performUIUpdatesOnMain {
                        //self.setUIEnabled(true)
                        //self.photoImageView.image = UIImage(data: imageData)
                        //self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                    }
                } else {
                    displayError("Image does not exist at \(imageURL)")
                }
            }
        }
        
        // start the task!
        task.resume()
        
        
    }
}
    
  
    
    

