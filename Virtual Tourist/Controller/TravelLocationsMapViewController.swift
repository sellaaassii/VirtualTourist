//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-05.
//  Copyright © 2020 Selasi. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self

        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            initMapViewRegionFromDefaults()
        } else {
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            setMapViewRegions()
        }
    }

    func setMapViewRegions() {
        let region = mapView.region
        let centerLongitude = region.center.longitude
        let centerLatitude = region.center.latitude
        
        let longitudinalMeters = region.span.longitudeDelta
        let latitudinalMeters = region.span.latitudeDelta
        
        UserDefaults.standard.set(centerLongitude, forKey: "CenterCoordinateLongitude")
        UserDefaults.standard.set(centerLatitude, forKey: "CenterCoordinateLatitude")
        UserDefaults.standard.set(latitudinalMeters, forKey: "RegionLatitudinalMetres")
        UserDefaults.standard.set(longitudinalMeters, forKey: "RegionLongitudinalMetres")
    }
    
    func initMapViewRegionFromDefaults() {
        let centerLongitude = UserDefaults.standard.double(forKey: "CenterCoordinateLongitude")
        let centerLatitude  = UserDefaults.standard.double(forKey: "CenterCoordinateLatitude")
        let latitudinalMeters  = UserDefaults.standard.double(forKey: "RegionLatitudinalMetres")
        let longitudinalMeters = UserDefaults.standard.double(forKey: "RegionLongitudinalMetres")
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let span = MKCoordinateSpan(latitudeDelta: latitudinalMeters, longitudeDelta: longitudinalMeters)
        
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
}

extension TravelLocationsMapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region did change fam")
        setMapViewRegions()
    }
}

