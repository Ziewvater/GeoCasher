//
//  ImageFetcher.swift
//  GeoCasher
//
//  Created by Jeremy Lawrence on 8/28/15.
//  Copyright © 2015 Ziewvater. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

let InstagramPostEndpoint = "http://localhost:8000/imagefeed.json"

class ImageFetcher: AnyObject {
    
    /**
    Fetches posts from the server.
    
    :param: completion Closure that fires at the successful completion of the net call. Gives access to array of posts fetched.
    :param: errorHandler Closure that fires if error is encountered in net fetch.
    */
    class func fetchPosts(completion: (posts: [Post]) -> Void, errorHandler: (error: NSError) -> Void) {
        Alamofire.request(.GET, InstagramPostEndpoint)
            .response { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> Void in
                // Handle error if received
                if let error = error {
                    errorHandler(error: error)
                    return
                }
                // Check for data, if not present complete with empty array
                guard let data = data else {
                    completion(posts: [])
                    return
                }
                
                let json = JSON(data: data)
                var posts = [Post]()
                json.forEach({ (_, postJSON) -> () in
                    if let post = Post(json: postJSON) {
                        posts.append(post)
                    }
                })
                completion(posts: posts)
        }
    }
}

/**
Represents a named location used in an Instagram post.
*/
struct Location {
    var coordinate: CLLocationCoordinate2D
    var name: String
}

/**
Represents an Instagram post received from the server.
*/
struct Post {
    /// Location associated with the post
    let location: Location
    /// URL to the image on the post
    let imageURL: NSURL
    
    init?(json: JSON) {
        guard let longitude = json["location"]["longitude"].double,
            let latitude = json["location"]["latitude"].double,
            let locationName = json["location"]["name"].string,
            let imageURL = json["images"]["standard_resolution"]["url"].URL else {
                NSLog("Failed to create Post from JSON, missing information: \(json)")
                return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.location = Location(coordinate: coordinate, name: locationName)
        self.imageURL = imageURL
    }
}
