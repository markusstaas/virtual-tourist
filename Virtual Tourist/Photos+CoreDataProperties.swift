//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 11/15/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var filePath: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
