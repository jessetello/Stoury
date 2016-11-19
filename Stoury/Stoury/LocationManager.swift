//
//  LocationManager.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 11/5/16.
//  Copyright © 2016 jt. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    func getLocation() {
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
