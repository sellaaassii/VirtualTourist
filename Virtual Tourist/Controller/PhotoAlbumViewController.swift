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
    var pin: Pin?
    var dataController: DataController!
    var selectedCoordinate: CLLocationCoordinate2D!
    var images: [Photo]   = [Photo]()


    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotoLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "OK"
        
        collectionView.delegate = self
        
        setupMapView()

        if let pin = pin {
            if let dbPhotos = pin.photos {

                if dbPhotos.count > 0 {
                    images = pin.photos?.allObjects as! [Photo]
                    collectionView.dataSource = self
                } else {
                    //  download Flickr images associated with the latitude and longitude of the pin
                    // While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled.
                    getNewLocationData(latitude: pin.latitude, longitude: pin.longitude)
                }

            }
        }
    }
    
    func setDownloading(_ downloading: Bool) {
        newCollectionButton.isEnabled = !downloading
    }

    @IBAction func newCollectionTapped(_ sender: Any) {
        setDownloading(true)
        pin?.photos = nil
        getNewLocationData(latitude: pin!.latitude, longitude: pin!.longitude)
    }
    
    func setupMapView() {
        mapView.delegate = self

        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate

        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: selectedCoordinate, latitudinalMeters: 600.0, longitudinalMeters: 600.0)
        mapView.setRegion(region, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataController.save()
    }

    func getNewLocationData(latitude: Double, longitude: Double) {
        setDownloading(true)
        images.removeAll()
        collectionView.reloadData()

        Client.getPhotosFromLocation(latitude: latitude, longitude: longitude) { photoArray, error in

            guard error == nil else {
                print("dat error thooo \(error!.localizedDescription)")
                return
            }

            if let photoArray = photoArray {
                
                if photoArray.count == 0 {
                    self.noPhotoLabel.isHidden = false
                } else {
                    self.noPhotoLabel.isHidden = true
                    for photo in photoArray {
                        let image = Photo(context: self.dataController.viewContext)
                        image.url = photo.urlString
                        self.images.append(image)
                    }
                }
            }

            self.collectionView.dataSource = self

            self.dataController.save()
            self.collectionView.reloadData()
            self.setDownloading(false)
        }
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor   = MKPinAnnotationView.redPinColor()
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        return pinView
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin!)
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


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        if let image = images[indexPath.row].image {
            cell.imageView.image = UIImage(data: image)
        } else {

            cell.activityIndicator.startAnimating()

            if let urlString = images[indexPath.row].url {
                DispatchQueue.global(qos: .default).async { [weak self] in
                    if let url = URL(string: urlString), let photo = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self?.images[indexPath.row].image = photo
                            cell.activityIndicator.stopAnimating()
                            cell.imageView.image = UIImage(data: photo)
                            
                            let photoToAdd = self?.images[indexPath.row]
                            self?.pin?.addToPhotos(photoToAdd!)

                            self?.dataController.save()
                        }
                    }
                }
            }
        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToRemove = images[indexPath.row]
        pin?.removeFromPhotos(photoToRemove)
        
        images.remove(at: indexPath.row)
        dataController.save()
        
        self.collectionView.deleteItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

}
