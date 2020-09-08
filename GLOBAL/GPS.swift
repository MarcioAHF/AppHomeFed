//
//  File.swift
//  AHF
//
//  Created by Nano on 20-06-01.
//

import Foundation
import MapKit

class GPS: NSObject, CLLocationManagerDelegate {

    static let shared = GPS()

    private var _testMode: Bool = false
    var testMode: Bool {
        get{ return _testMode }
        set{
            _testMode = newValue
            if _testMode { setTestMode() }
        }
    }
    
    var ready: Bool = false
    var currentLocation: CLLocation!
    var coord2d: Coord!
    lazy var lat = coord2d.lat
    lazy var long = coord2d.long
    
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways)
        {
            currentLocation = locationManager.location
        }
        
        if CLLocationManager.headingAvailable()
        {
            locationManager.headingFilter = 5
            locationManager.startUpdatingHeading()
        }
        setTestMode()
    }
    
    // :CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let lastLocation = locations.last! as CLLocation
        coord2d = Coord(coord: lastLocation.coordinate)
        locationReady()
    }
    
    @objc func locationReady() {
        ready = true
        NotificationCenter.default.post(name: .gps , object: nil)
    }
    
    func setTestMode() {
        lat  =  45.54071
        long = -73.60560
        currentLocation = CLLocation(
            latitude: CLLocationDegrees(lat.double),
            longitude: CLLocationDegrees(long.double))
        coord2d = Coord(coord: currentLocation.coordinate)
    }
}
