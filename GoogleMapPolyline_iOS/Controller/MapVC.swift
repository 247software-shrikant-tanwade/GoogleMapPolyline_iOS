//
//  MapVC.swift
//  GoogleMapPolyline_iOS
//
//  Created by Shrikant Tanwade on 31/10/18.
//  Copyright © 2018 shrikant. All rights reserved.
// 

import UIKit
import GoogleMaps

class MapVC: UIViewController {

    // MARK: - IBOutlet and Variables
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var btnWhereToGo : UIButton!
    
    var locationManager = CLLocationManager()
    var currentLatLong : CLLocationCoordinate2D!
    

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: - Button Action
    @IBAction func btnDirectionAction(_ sender: UIButton) {
        self.btnWhereToGo.isHidden = true
        SearchPlacesListVC.presentWith(delegate: self, presenterVC: self,currentLatLong:currentLatLong)
    }
}

// MARK: - CLLocationManagerDelegate Delegate
extension MapVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        mapView.clear()
        currentLatLong = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        mapView.addMarker(location: currentLatLong, address: "", shortAddress: "")
        self.locationManager.stopUpdatingLocation()
    }
}

// MARK: - SearchPlacesListVCDelegate Delegate
extension MapVC : SearchPlacesListVCDelegate {
    func addFromMarker(location: CLLocationCoordinate2D, address: String, shortAddress: String) {
        mapView.clear()
        mapView.addMarker(location: location, address: address, shortAddress: shortAddress)
    }
    
    func addToMarker(location: CLLocationCoordinate2D, address: String, shortAddress: String) {
        mapView.addMarker(location: location, address: address, shortAddress: shortAddress)
    }
    
    func addMarkerAndDrawPloyline(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        GoogleApiManager.polylineRoute(from: from, to: to, on: self.mapView) { (arrRouteLatLong) in
            _ = CarMarker.init(mapView: self.mapView, routeLatLongs: arrRouteLatLong)
        }
    }
    
    func dismissSearchPlacesListVC() {
        self.btnWhereToGo.isHidden = false
    }
}



