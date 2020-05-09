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

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "OK"
        
        print("le pin fame \(pin.latitude)")
        
        newCollectionButton.isEnabled = false
        
        
        //  download Flickr images associated with the latitude and longitude of the pin
        Client.getPhotosFromLocation(latitude: pin.latitude, longitude: pin.longitude) { data, error in
            print(data)
            print(error)
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
