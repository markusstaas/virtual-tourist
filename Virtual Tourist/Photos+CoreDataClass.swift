//
//  Photos+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/9/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//
//
import UIKit
import Foundation
import CoreData


public class Photos: NSManagedObject {
    var image: UIImage? {
        
        if let filePath = photoPath {
            let fileName = (filePath as NSString).lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)
            return UIImage(contentsOfFile: fileURL!.path)
        }
        return nil
        
    }
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: "Photos", in: context)!
        super.init(entity: entity, insertInto: context)
        self.photoURL = photoURL
        self.location = pin
    }

    override public func prepareForDeletion(){
        super.prepareForDeletion()
        if photoPath != nil{
            let fileName = (photoPath! as NSString).lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                print("Error - \(error)")
            }
        } else { print("Filepath empty")}
    }

}
