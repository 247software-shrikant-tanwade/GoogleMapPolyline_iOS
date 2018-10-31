//
//  AppExtensions.swift
//  GoogleMapPolyline_iOS
//
//  Created by Shrikant Tanwade on 31/10/18.
//  Copyright © 2018 shrikant. All rights reserved.
//

import Foundation
import GoogleMaps

extension GMSMapView {
    func addMarker(location : CLLocationCoordinate2D, address : String, shortAddress : String) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,longitude: location.longitude, zoom: 13.0)
        self.animate(to: camera)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        marker.title = address
        marker.snippet = shortAddress
        marker.map = self
    }
    
    func showPath(polyStr :String) {
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = kPolyLineStrokeColor
        polyline.map = self
    }
}
