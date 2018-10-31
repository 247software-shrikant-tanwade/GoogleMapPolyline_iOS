//
//  RouteConstant.swift
//  GoogleMapPolyline_iOS
//
//  Created by Shrikant Tanwade on 31/10/18.
//  Copyright © 2018 shrikant. All rights reserved.
//

import Foundation
import GoogleMaps

var carLocationLatLongCount : Int = 0

class CarMarker {
    var carMarker : GMSMarker!
    var timer : Timer!
    var arrLatLongs : [CLLocationCoordinate2D]!
    
    init(mapView:GMSMapView,routeLatLongs:[CLLocationCoordinate2D]) {
        carMarker = GMSMarker()
        carMarker.position = routeLatLongs[0]
        carMarker.icon = kCarMarkerImage
        carMarker.map = mapView
        
        carLocationLatLongCount = 0
        arrLatLongs = routeLatLongs
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        if carLocationLatLongCount < arrLatLongs.count {
            carMarker.position = arrLatLongs[carLocationLatLongCount]
            carLocationLatLongCount = carLocationLatLongCount + 1
        } else {
            timer.invalidate()
        }
    }
}


