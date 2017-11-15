//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/15/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pageNumber: NSNumber?
    @NSManaged public var pinTitle: String?
    @NSManaged public var photos: Photos?

}
