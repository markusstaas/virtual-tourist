//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Markus Staas on 11/13/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Pin: NSManagedObject {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(lat: Double, long: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        super.init(entity: entity, insertInto: context)
        self.lat = lat
        self.long = long
        self.pageNumber = 0
    }
    
  
}
