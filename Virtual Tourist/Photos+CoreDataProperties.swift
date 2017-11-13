//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/9/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var photoID: String?
    @NSManaged public var photoTitle: String?
    @NSManaged public var photoURL: String?
    @NSManaged public var photoPath: String?
    @NSManaged public var location: Pin?

}
