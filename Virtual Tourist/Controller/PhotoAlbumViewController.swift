//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-06.
//  Copyright © 2020 Selasi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var dataController: DataController!
    var photos:[PhotoResponse]!

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "OK"
        
//        print("le pin fam \(pin.latitude ?? nil)")
        
        newCollectionButton.isEnabled = false
        
    
        //  download Flickr images associated with the latitude and longitude of the pin
        Client.getPhotosFromLocation(latitude: pin.latitude, longitude: pin.longitude) { data, error in
            print(data)
            print(error)
            
            guard error == nil else {
                print("dat error thooo")
                return
            }

            if let data = data {
                if let numberOfPhotos = Int(data.total) {
                    
                    if numberOfPhotos > 0 {
                        self.photos = data.photo
                        // create images from response
                    } else {
                        self.newCollectionButton.isEnabled = true
                    }
                    
                }
            }
            
        }
        
        // While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled.
        
        //  The app should determine how many images are available for the pin location, and display a placeholder image for each.
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.activityIndicator.startAnimating()
        
        for photo in photos {
            let urls = photo.urlString
            
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
        return 0
    }
    
    
}
