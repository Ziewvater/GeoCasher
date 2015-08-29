//
//  PostLocationViewController.swift
//  GeoCasher
//
//  Created by Jeremy Lawrence on 8/29/15.
//  Copyright © 2015 Ziewvater. All rights reserved.
//

import UIKit
import MapKit

let DefaultMapDistance: CLLocationDistance = 1000

class PostLocationViewController: UIViewController {

    var post: Post!
    
    weak var mapView: MKMapView!
    
    override func loadView() {
        super.loadView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonTapped:")
        navigationItem.title = post.location.name
        
        let map = MKMapView()
        view.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        map.mapType = .Satellite
        map.setRegion(MKCoordinateRegionMakeWithDistance(post.location.coordinate, DefaultMapDistance, DefaultMapDistance), animated: false)
        let point = MKPointAnnotation()
        point.coordinate = post.location.coordinate
        map.addAnnotation(point)
        mapView = map
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
