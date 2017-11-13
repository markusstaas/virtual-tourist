//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Markus Staas on 11/13/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var pageNumber: Int32
    @NSManaged public var photos: Photos?

}
