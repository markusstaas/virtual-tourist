//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/13/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import UIKit
import Foundation
import CoreData
import SystemConfiguration

class FlickrClient: NSObject {
    
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: - GET request
    
    func taskForGETMethodWithParameters(_ parameters: [String : AnyObject],
                                        completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let urlString = FlickrAPI.Constants.BaseURL + FlickrClient.escapedParameters(parameters)
        let request = URLRequest(url: URL(string: urlString)!)
        
        let task = session.dataTask(with: request, completionHandler: {
            data, response, downloadError in
            
            if let error = downloadError {
                let newError = FlickrClient.errorForResponse(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
    }
    
    // MARK: POST
    func taskForGETMethod(_ urlString: String,
                          completionHandler: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        
        let request = URLRequest(url: URL(string: urlString)!)
        
        let task = session.dataTask(with: request, completionHandler: {
            data, response, downloadError in
            
            if let error = downloadError {
                
                let newError = FlickrClient.errorForResponse(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                
                completionHandler(data, nil)
            }
        })
        
        task.resume()
        
    }
    
    // MARK: - Helpers
    
    class func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsingError: NSError?
        let parsedResult: Any?
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
            print("Parse error - \(parsingError!.localizedDescription)")
            return
        }
        
        if let error = parsingError {
            completionHandler(nil, error)
        } else {
            completionHandler(parsedResult as AnyObject?, nil)
        }
        
    }
    
    
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            if(!key.isEmpty) {
          
                let stringValue = "\(value)"

                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

                urlVars += [key + "=" + "\(escapedValue!)"]
            }
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    class func errorForResponse(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as? [String : AnyObject] {
            
            if let status = parsedResult[FlickrAPI.FlickrResponseKeys.Status]  as? String,
                let message = parsedResult[FlickrAPI.FlickrResponseKeys.Message] as? String {
                
                if status == FlickrAPI.FlickrResponseValues.Fail {
                    
                    let userInfo = [NSLocalizedDescriptionKey: message]
                    
                    return NSError(domain: "Virtual Tourist Error", code: 1, userInfo: userInfo)
                }
            }
        }
        return error
    }

    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
}

