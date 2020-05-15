//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-05.
//  Copyright © 2020 Selasi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedCoordinate: CLLocationCoordinate2D!

    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var newPin: Pin!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            initMapViewRegionFromDefaults()
        } else {
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            setMapViewRegions()
        }
    
        addLongPressListenerToMapView()

        setupFetchedResultsController()

        addAnnotationsToMapFromFetchedObjects()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedAnnotations = mapView.selectedAnnotations

        for annotation in selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }

        newPin = nil

        setupFetchedResultsController()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let selectedAnnotations = mapView.selectedAnnotations

        for annotation in selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }

        dataController.save()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    func initMapViewRegionFromDefaults() {
        let centerLongitude = UserDefaults.standard.double(forKey: "CenterCoordinateLongitude")
        let centerLatitude  = UserDefaults.standard.double(forKey: "CenterCoordinateLatitude")
        let latitudinalMeters  = UserDefaults.standard.double(forKey: "RegionLatitudinalMetres")
        let longitudinalMeters = UserDefaults.standard.double(forKey: "RegionLongitudinalMetres")
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let span   = MKCoordinateSpan(latitudeDelta: latitudinalMeters, longitudeDelta: longitudinalMeters)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }

    func setMapViewRegions() {
        let region = mapView.region
        let centerLongitude = region.center.longitude
        let centerLatitude  = region.center.latitude
        
        let longitudinalMeters = region.span.longitudeDelta
        let latitudinalMeters  = region.span.latitudeDelta
        
        UserDefaults.standard.set(centerLongitude, forKey: "CenterCoordinateLongitude")
        UserDefaults.standard.set(centerLatitude, forKey: "CenterCoordinateLatitude")
        UserDefaults.standard.set(latitudinalMeters, forKey: "RegionLatitudinalMetres")
        UserDefaults.standard.set(longitudinalMeters, forKey: "RegionLongitudinalMetres")
    }
    
    func addLongPressListenerToMapView() {
        let longPressListener = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressListener)
    }

    @objc func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        print("long press initiaitaed")
        let pointOnMap          = gestureRecognizer.location(in: mapView)
        let coordinateFromPoint = mapView.convert(pointOnMap, toCoordinateFrom: mapView)
        
        let annotation        = MKPointAnnotation()
        annotation.coordinate = coordinateFromPoint
        
        mapView.addAnnotation(annotation)

        let pin = Pin(context: dataController.viewContext)
        pin.latitude  = coordinateFromPoint.latitude
        pin.longitude = coordinateFromPoint.longitude
        pin.page      = Int32(0)

        newPin = pin

        mapView.reloadInputViews()
        dataController.save()
        addLongPressListenerToMapView()
    }
    
    func addAnnotationsToMapFromFetchedObjects() {
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                let latitude   = CLLocationDegrees(pin.latitude)
                let longitude  = CLLocationDegrees(pin.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation        = MKPointAnnotation()
                annotation.coordinate = coordinate

                mapView.addAnnotation(annotation)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoAlbum" {
            let controller = segue.destination as! PhotoAlbumViewController
            controller.dataController     = dataController
            controller.selectedCoordinate = selectedCoordinate
            
            if let pin = self.newPin {
                controller.pin = pin
            } else {

                if let fetchedPins = fetchedResultsController.fetchedObjects {
                    for pin in fetchedPins {
                        if pin.latitude == selectedCoordinate.latitude && pin.longitude == selectedCoordinate.longitude {
                            controller.pin = pin
                            break
                        }
                    }
                }

            }
        }
    }
}

extension TravelLocationsMapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setMapViewRegions()
    }
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = mapView.selectedAnnotations[0]
        selectedCoordinate     = selectedAnnotation.coordinate

        performSegue(withIdentifier: "showPhotoAlbum", sender: nil)
    }
}

