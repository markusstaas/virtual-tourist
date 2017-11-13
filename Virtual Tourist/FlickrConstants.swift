//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Markus Staas (Lazada eLogistics Group) on 10/23/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import Foundation

// MARK: - Constants
struct FlickrAPI{
struct Constants {
    
    // API Key
    static let APIKey = "df1c8e24162af5e93c1935e24018579a"
    
    // Base URL
    static let BaseURL = "https://api.flickr.com/services/rest/"
}

// MARK: - Methods
struct Methods {
    static let Search = "flickr.photos.search"
}

// MARK: - URL Keys
struct FlickrParameterKeys {
    static let APIKey = "api_key"
    static let BoundingBox = "bbox"
    static let Format = "format"
    static let Extras = "extras"
    static let Latitude = "lat"
    static let Longitude = "lon"
    static let Method = "method"
    static let NoJSONCallback = "nojsoncallback"
    static let Page = "page"
    static let PerPage = "per_page"
}

// MARK: - URL Values
struct FlickrParameterValues {
    static let JSONFormat = "json"
    static let URLMediumPhoto = "url_m"
}

// MARK: - JSON Response Keys
struct FlickrResponseKeys {
    static let Status = "stat"
    static let Code = "code"
    static let Message = "message"
    static let Pages = "pages"
    static let Photos = "photos"
    static let Photo = "photo"
}

// MARK: - JSON Response Values

struct FlickrResponseValues {
    
    static let Fail = "fail"
    static let Ok = "ok"
}
}
