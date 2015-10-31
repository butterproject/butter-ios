//
//  RestApiManager.swift
//  Butter
//
//  Created by DjinnGA on 25/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    var task: NSURLSessionDataTask? = nil
    
    func cancelRequest() {
        if (task != nil) {
            task!.cancel()
            task = nil
        }
    }
    
    func getJSONFromURL(url:String, onCompletion: (JSON) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        makeHTTPRequest(request, onCompletion: { json, err in
            dispatch_async(dispatch_get_main_queue()) {
                onCompletion(json as JSON)
            }
        })
    }
    
    func getJSONFromURL(url:String, parameters:[String:AnyObject], onCompletion: (JSON) -> Void) {
        getJSONFromURL(url, headers: nil, parameters: parameters) { (json) -> Void in
            onCompletion(json)
        }
    }
    
    func getJSONFromURL(url:String, headers: [String:String]?, parameters:[String:AnyObject], onCompletion: (JSON) -> Void) {
        
        let urlToRequest = "\(url)?\(parameters.queryStringWithEncoding())"
        let request = NSMutableURLRequest(URL: NSURL(string: urlToRequest)!)
        
        print(urlToRequest)
        
        if let headers = headers {
            for (field, value) in headers {
                request.addValue(value, forHTTPHeaderField: field)
            }
        }
        
        makeHTTPRequest(request, onCompletion: { json, err in
            dispatch_async(dispatch_get_main_queue()) {
                onCompletion(json as JSON)
            }
        })
    }
    
    func getJSONFromURL(url:NSMutableURLRequest, onCompletion: (JSON) -> Void) {
        makeHTTPRequest(url, onCompletion: { json, err in
            dispatch_async(dispatch_get_main_queue()) {
                onCompletion(json as JSON)
            }
        })
    }
    
	func makeHTTPRequest(path: NSMutableURLRequest, onCompletion: ServiceResponse) {
		path.timeoutInterval = 5.0
		let session = NSURLSession.sharedSession()
		UIApplication.sharedApplication().beganNetworkActivity()
		task = session.dataTaskWithRequest(path, completionHandler: {data, response, error -> Void in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().endedNetworkActivity()
				
				if let error = error {
					print(error)
					NSNotificationCenter.defaultCenter().postNotificationName("NSURLErrorDomainErrors", object: self, userInfo: ["error" : error])
				}
				
				if let data = data {
					let json:JSON = JSON(data: data)
					onCompletion(json, error)
				} else {
					onCompletion(JSON(""), error)
				}
			}
		})
		task!.resume()
	}
	
    func makeAsyncDataRequest(url: String, onCompletion: (NSData) -> Void) {
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string:url)!)
        let mainQueue = NSOperationQueue.mainQueue()
		UIApplication.sharedApplication().beganNetworkActivity()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().endedNetworkActivity()
				if error == nil {
					onCompletion(data!)
				} else {
					print("Error: \(error!.localizedDescription)")
				}
			}
        })
    }
    
    func loadImage(url:String, onCompletion: (UIImage) -> Void) {
        if (url != "") {
            self.makeAsyncDataRequest(url) { data in
                if let image = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue(), {
                        onCompletion(image)
                    })
                } else {
                    print("Could Not Load: \(url)")
                }
            }
        }
    }
}