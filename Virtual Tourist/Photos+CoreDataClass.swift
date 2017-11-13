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
            
            // Check to see if there's an error downloading the images for each Pin
            if filePath == "error" {
                //return UIImage(named: "404.jpg")
                print("Filepath error")
            }
            
            // Get the file path
            let fileName = (filePath as NSString).lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)
            
            return UIImage(contentsOfFile: fileURL!.path)
        }
        return nil
        
    }
    
    // MARK: - Init model
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entity(forEntityName: "Photos", in: context)!
        super.init(entity: entity, insertInto: context)
        self.photoURL = photoURL
        self.location = pin
        
    }
    
    //MARK: - Delete file when deleting a managed object
    
    // Explicitely deletes the underlying files
    override public func prepareForDeletion(){
        super.prepareForDeletion()
        
        if photoPath != nil{
            // Delete the associated image file when the Photos managed object is deleted.
            let fileName = (photoPath! as NSString).lastPathComponent
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                print("Error from prepareForDeletion - \(error)")
            }
        } else { print("filepath is empty")}
    }

}
