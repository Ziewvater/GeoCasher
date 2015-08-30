//
//  LocationPermissionHandler.swift
//  GeoCasher
//
//  Created by Jeremy Lawrence on 8/29/15.
//  Copyright © 2015 Ziewvater. All rights reserved.
//

import UIKit
import CoreLocation

typealias LocationClosureType = (location: CLLocation) -> Void

/**
Handles asking for location permission, returning current location.
Subclasses NSObject to conform to CLLocationManagerDelegate

The LocationPermissionHandler performs the necessary actions required to request access to location data for the app. It also handles presenting descriptive alert views to prime the user for granting location data access (as http://www.useronboard.com/ advises).

Wrapping this process allows us to react to permission denials where we would normally miss them since successive calls to `CLLocationManager.request*Authorization()` fail silently when permission is denied. We could just try immediately asking for location services permissions when authorization status is .NotDetermined, and this process would still work, but I think adding the priming alert makes the app experience more conversational and friendly, even if it means we're showing two alerts in a row.
*/
class LocationPermissionHandler: NSObject {

    static let sharedInstance = LocationPermissionHandler()
    
    let locationManager: CLLocationManager
    private var completion: ((location: CLLocation) -> Void)?
    var location: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    /**
    Attempts to fetch the device's current location, and executes a closure when the location is received.
    
    If the app is already permitted to use location services, the LocationPermissionHandler immediately requests the current location, and executes the locationHandler closure when the location is received.
    
    If the user has not yet given permission to the app, the user is prompted with an alert describing what the app uses location data for.
    
    If the user has denied access to location services or have restricted access to location services, they are prompted to grant access through the Settings app, or directed to ask someone to change their account settings.
    
    :param: alertPresentationViewController View controller to present descriptive alert views.
    :param: locationHandler                 Closure to be called upon successfully receving device location
    */
    func getCurrentLocationWithPresentationViewController(alertPresentationViewController: UIViewController, locationHandler: LocationClosureType) {
        completion = locationHandler
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined: // User hasn't made a decision on location services yet
            let alertController = UIAlertController(title: "GeoCasher needs location", message: "GeoCasher needs access to your current location to sort photos by location, and to show your location in relation to a post's on a map. We don't use your location data for anything else.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { [unowned self] (action: UIAlertAction) -> Void in
                self.locationManager.requestWhenInUseAuthorization()
            }))
            alertController.addAction(UIAlertAction(title: "Not Now", style: .Cancel, handler: nil))
            alertPresentationViewController.presentViewController(alertController, animated: true, completion: nil)
            
        case .Restricted: // Restricted access means the user isn't allowed to grant access, probably because of parental controls
            let alertController = UIAlertController(title: "GeoCasher needs location", message: "GeoCasher needs access to current location to sort photos by location. Please ask the account owner to grant GeoCasher access to location services", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            alertPresentationViewController.presentViewController(alertController, animated: true, completion: nil)
        
        case .Denied: // User denied access. Direct to settings to change permission settings
            let alertController = UIAlertController(title: "GeoCasher needs location", message: "GeoCasher needs access to current location to sort photos by location. Please grant GeoCasher access to your location in Settings", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action: UIAlertAction) -> Void in
                guard let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                UIApplication.sharedApplication().openURL(settingsURL)
            }))
            alertController.addAction(UIAlertAction(title: "Not Now", style: .Cancel, handler: nil))
            alertPresentationViewController.presentViewController(alertController, animated: true, completion: nil)
            
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            // Get location and execute caller's closure when received
            locationManager.requestLocation()
        }
    }
}

extension LocationPermissionHandler: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            locationManager.requestLocation()
        case .Denied, .Restricted: () // If denied at this point, don't bug the user
        default: break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            NSLog("Did not receive lcoations")
            return
        }
        self.location = location
        completion?(location: location)
        completion = nil
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location manager encountered error: \(error)")
    }
    
}
