//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Markus Staas on 7/22/17.
//  Copyright © 2017 Markus Staas. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
