//
//  Photos+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/15/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Photos)
public class Photos: NSManagedObject {
    
    var image: UIImage? {
        if let filePath = filePath {
            if filePath == "error" {
                print("Error: No filepath")
            }
            let fileName = (filePath as NSString).lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)
            return UIImage(contentsOfFile: fileURL!.path)
        }
        return nil
    }

    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: "Photos", in: context)!
        super.init(entity: entity, insertInto: context)
        self.url = photoURL
        self.pin = pin
    }
    
    override public func prepareForDeletion(){
        super.prepareForDeletion()
        
        if filePath != nil{
            let fileName = (filePath! as NSString).lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                print("\(error)")
            }
        } else { print("Error: No filepath")}
    }
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    

}
