//
//  LocationManager.swift
//  GoogleMapPolyline_iOS
//
//  Created by Shrikant Tanwade on 31/10/18.
//  Copyright © 2018 shrikant. All rights reserved.
//

import Foundation
import GoogleMaps



struct GoogleMapUrl {
    let searchPlaces = "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=\(GoogleMap().geoCodingKey)&language=en&sensor=true&region=GB&input="
    let latLong = "https://maps.googleapis.com/maps/api/place/details/json?&key=\(GoogleMap().geoCodingKey)&placeid="
    let polylineRoute = "https://maps.googleapis.com/maps/api/directions/json?key=\(GoogleMap().geoCodingKey)&sensor=true&mode=driving"
}

struct Places {
    let description : String!
    let placeId : String!
}

class GoogleApiManager {
    
    static func jsonResponseWith(strUrl:String,complationHandler: @escaping (_ success: Bool, _ jsonResponse: [String:Any]) -> ()) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if let url = URL(string: strUrl) {
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if let json = dataToJSON(data: data!) as? [String:AnyObject]  {
                        DispatchQueue.main.async {
                            complationHandler(true, json)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    static func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func placesOf(searchText: String,complationHandler: @escaping (_ success: Bool, _ places: [Places]) -> ()) {
        
        let url : String = GoogleMapUrl().searchPlaces + searchText.lowercased()
        
        self.jsonResponseWith(strUrl: url, complationHandler: { (success, jsonResponse) in
            if let arrRowPlaces = jsonResponse["predictions"] as? [[String : AnyObject]] {
                var arrFliterPlaces = [Places]()
                for dictPlace in arrRowPlaces {
                    let place = Places(description: dictPlace["description"] as? String ?? "", placeId: dictPlace["place_id"] as? String ?? "")
                    arrFliterPlaces.append(place)
                }
                complationHandler(true, arrFliterPlaces)
            }
        })
    }
    
    static func latLongFrom(placeId: String,complationHandler: @escaping (_ success: Bool, (latitude:Double,longitude:Double)) -> ()) {
        
        let url : String = GoogleMapUrl().latLong + placeId
        
        self.jsonResponseWith(strUrl: url, complationHandler: { (success, json) in
            if (((json["result"] as! [String:AnyObject])["geometry"]?["location"]) as! [String:AnyObject])["lat"] as? Double != nil   {
                let latitude = (((json["result"] as! [String:AnyObject])["geometry"]?["location"]) as! [String:AnyObject])["lat"] as! Double
                let longitude = (((json["result"] as! [String:AnyObject])["geometry"]?["location"]) as! [String:AnyObject])["lng"] as! Double
                complationHandler(true,(latitude,longitude))
            }
        })
    }
    
    static func polylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, on mapView : GMSMapView, complationHandler: @escaping (_ arrRouteLagLongs: [CLLocationCoordinate2D]) -> ()) {
        
        let url : String = GoogleMapUrl().polylineRoute + "&origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)"
        
        self.jsonResponseWith(strUrl: url, complationHandler: { (success, json) in
            if let routes = json["routes"] as? NSArray {
                if (routes.count > 0) {
                    if let overview_polyline = routes[0] as? NSDictionary {
                        if let dictPolyline = overview_polyline["overview_polyline"] as? NSDictionary {
                            if  let points = dictPolyline.object(forKey: "points") as? String {
                                mapView.showPath(polyStr: points)
                                
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 170, left: 30, bottom: 30, right: 30))
                                mapView.moveCamera(update)
                            }
                        }
                        
                        
                        if let legs = overview_polyline["legs"] as? NSArray {
                            if let legsDict = legs[0] as? NSDictionary {
                                if let steps = legsDict["steps"] as? NSArray {
                                    var arrRouteLagLongs = [CLLocationCoordinate2D]()
                                    for step in steps {
                                        if let stepDict = step as? NSDictionary {
                                            if let endLocationDict = stepDict["end_location"] as? [String:Any] {
                                                let lat = endLocationDict["lat"] as! Double
                                                let long = endLocationDict["lng"] as! Double
                                                arrRouteLagLongs.append(CLLocationCoordinate2D(latitude: lat, longitude: long))
                                            }
                                        }
                                    }
                                    complationHandler(arrRouteLagLongs)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
}
