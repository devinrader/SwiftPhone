//
//  SwiftRequest.swift
//  SwiftRequestTest
//
//  Created by Ricky Robinett on 6/20/14.
//  Copyright (c) 2015 Ricky Robinett. All rights reserved.
//

import Foundation

public class SwiftRequest {
    var session = NSURLSession.sharedSession()
    
    public init() {
        // we should probably be preparing something here...
    }
    
    // GET requests
    public func get(url: String, auth: [String: String] = [String: String](), params: [String: String] = [String: String](), callback: ((err: NSError?, response: NSHTTPURLResponse?, body: AnyObject?)->())? = nil) {
        let qs = dictToQueryString(params)
        request(["url" : url, "auth" : auth, "querystring": qs ], callback: callback )
    }
    
    // POST requests
    public func post(url: String, data: [String: String] = [String: String](), auth: [String: String] = [String: String](), callback: ((err: NSError?, response: NSHTTPURLResponse?, body: AnyObject?)->())? = nil) {
        let qs = dictToQueryString(data)
        request(["url": url, "method" : "POST", "body" : qs, "auth" : auth] , callback: callback)
    }
    
    // Actually make the request
    func request(options: [String: Any], callback: ((err: NSError?, response: NSHTTPURLResponse?, body: AnyObject?)->())?) {
        if( options["url"] == nil ) { return }
        
        var urlString = options["url"] as! String
        if( options["querystring"] != nil && (options["querystring"] as! String) != "" ) {
            let qs = options["querystring"] as! String
            urlString = "\(urlString)?\(qs)"
        }
        
        let url = NSURL(string:urlString)
        let urlRequest = NSMutableURLRequest(URL: url!)
        
        if( options["method"] != nil) {
            urlRequest.HTTPMethod = options["method"] as! String
        }
        
        if( options["body"] != nil && options["body"] as! String != "" ) {
            let postData = (options["body"] as! String).dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
            urlRequest.HTTPBody = postData
            urlRequest.setValue("\(postData!.length)", forHTTPHeaderField: "Content-length")
        }
        
        // is there a more efficient way to do this?
        if( options["auth"] != nil && (options["auth"] as! [String: String]).count > 0) {
            var auth = options["auth"] as! [String: String]
            if( auth["username"] != nil && auth["password"] != nil ) {
                let username = auth["username"]
                let password = auth["password"]
                let authEncoded = "\(username!):\(password!)".dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions());
                print(authEncoded)
                let authValue = "Basic \(authEncoded)"
                urlRequest.setValue(authValue, forHTTPHeaderField: "Authorization")
            }
        }
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: {body, response, err in
            let resp = response as! NSHTTPURLResponse?
            
            if( err == nil) {
                if(response!.MIMEType == "text/html") {
                    let bodyStr = NSString(data: body!, encoding:NSUTF8StringEncoding)
                    return callback!(err: err, response: resp, body: bodyStr)
                } else if(response!.MIMEType == "application/json") {
                    var json: AnyObject?
                    var localError: NSError?

                    do {
                        json = try NSJSONSerialization.JSONObjectWithData(body! as NSData, options: NSJSONReadingOptions.MutableContainers)
                    } catch let parseError as NSError {
                        print(parseError)
                        localError = parseError
                    }
                    
                    return callback!(err: localError, response: resp, body: json);
                }
            }
            
            return callback!(err: err, response: resp, body: body)
        })
        
        task.resume()
    }
    
    func request(url: String, callback: ((err: NSError?, response: NSHTTPURLResponse?, body: AnyObject?)->())? = nil) {
        request(["url" : url ], callback: callback )
    }
    
    private func dictToQueryString(data: [String: String]) -> String {
        
        var qs = ""
        for (key, value) in data {
            let encodedKey = encode(key)
            let encodedValue = encode(value)
            qs += "\(encodedKey)=\(encodedValue)&"
        }
        return qs
    }
    
    private func encode(value: String) -> String {
        let queryCharacters =  NSCharacterSet(charactersInString:" =\"#%/<>?@\\^`{}[]|&+").invertedSet
        
        let encodedValue:String = value.stringByAddingPercentEncodingWithAllowedCharacters(queryCharacters)!
        
        return encodedValue
    }
}