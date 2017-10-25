//
//  FlickrCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Markus Staas on 10/20/17.
//  Copyright © 2017 Markus Staas . All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FlickrCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        getImagesFromFlickr()
    }
    
    func getImagesFromFlickr(){
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=df1c8e24162af5e93c1935e24018579a&lat=10.8231&lon=106.6297&extras=url_m&format=json&nojsoncallback=1"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if let data = data{
                    
                    let parsedResult: [String:AnyObject]!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    }catch{
                        print("Could not parse the data")
                        return
                    }
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                        
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
                        
                    }
                   // print(parsedResult)
                }
            }
        }
        
        task.resume()

    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    

}
