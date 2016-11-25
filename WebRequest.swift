//
//  WebRequest.swift
//  JsonResponse
//
//  Created by Active Mac05 on 25/11/16.
//  Copyright © 2016 techactive. All rights reserved.
//

import Foundation

class WebRequest: NSObject {
    let request: NSMutableURLRequest
    
    init(method: String, url: String) {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request.HTTPMethod = method
    }
    
    class func GET(url: String) -> WebRequest {
        return WebRequest(method: "GET", url: url)
    }
    
    class func POST(url: String) -> WebRequest {
        return WebRequest(method: "POST", url: url)
    }
    
    class func PUT(url: String) -> WebRequest {
        return WebRequest(method: "PUT", url: url)
    }
    
    class func DELETE(url: String) -> WebRequest {
        return WebRequest(method: "DELETE", url: url)
    }
    
    func setHeader(value: String, key: String) -> WebRequest {
        self.request.addValue(value, forHTTPHeaderField: key)
        return self
    }
    
    func setBodyWithString(string: String) -> WebRequest {
        return self.setBody(string.dataUsingEncoding(NSUTF8StringEncoding))
    }
    
    func setBody(data: NSData?) -> WebRequest {
        self.request.HTTPBody = data
        return self
    }
    
    func send(done: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        let task = NSURLSession
            .sharedSession()
            .dataTaskWithRequest(self.request, completionHandler: done)
        task.resume()
        return task
    }
}
