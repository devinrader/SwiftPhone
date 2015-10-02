//
//  Phone.swift
//  SwiftPhone
//
//  Created by Devin Rader on 1/30/15.
//  Copyright (c) 2015 Devin Rader. All rights reserved.
//

import Foundation

let SPDefaultClientName:String = "jenny"
let SPBaseCapabilityTokenUrl:String = "http://example.com/generateToken?%@"
let SPTwiMLAppSid:String = "APxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

public class Phone : NSObject, TCDeviceDelegate {
    var device:TCDevice!
    var connection:TCConnection!
    var pendingConnection:TCConnection!
    
    func login() {
    
        TwilioClient.sharedInstance().setLogLevel(TCLogLevel.LOG_VERBOSE)
        
        let url:String = self.getCapabilityTokenUrl()
        
        let swiftRequest = SwiftRequest()
        swiftRequest.get(url, callback: { (err, response, body) -> () in
            if err != nil {
                return
            }
            
            let token = NSString(data: body as! NSData, encoding: NSUTF8StringEncoding) as! String
            print(token)
            
            if err == nil && token != "" {
                if self.device == nil {
                    self.device = TCDevice(capabilityToken: token as String, delegate: self)
                }
                else {
                    self.device!.updateCapabilityToken(token)
                }
            }
            else if err != nil && response != nil {
                // We received and error with a response
            }
            else if err != nil {
                // We received an error without a response
            }
        })
    }
    
    func getCapabilityTokenUrl() -> String {
        
        var querystring:String = String()
        
        querystring += String(format:"&sid=%@", SPTwiMLAppSid)
        querystring += String(format:"&name=%@", SPDefaultClientName)

        return String(format:SPBaseCapabilityTokenUrl, querystring)
    }

    func connectWithParams(params dictParams:Dictionary<String,String> = Dictionary<String,String>()) {
        if !self.capabilityTokenValid() {
            self.login()
        }
        
        self.connection = self.device?.connect(dictParams, delegate: nil)
    }
    
    func acceptConnection() {
        self.connection = self.pendingConnection
        self.pendingConnection = nil
        
        self.connection?.accept()
    }
    
    func rejectConnection() {
        self.pendingConnection?.reject()
        self.pendingConnection = nil
    }
    
    func ignoreConnection() {
        self.pendingConnection?.ignore()
        self.pendingConnection = nil
    }

    func capabilityTokenValid()->(Bool) {
        var isValid:Bool = false
    
        if self.device != nil {
            let capabilities = self.device!.capabilities! as NSDictionary
        
            let expirationTimeObject:NSNumber = capabilities.objectForKey("expiration") as! NSNumber
            let expirationTimeValue:Int64 = expirationTimeObject.longLongValue
            let currentTimeValue:NSTimeInterval = NSDate().timeIntervalSince1970
        
            if (expirationTimeValue-Int64(currentTimeValue)) > 0 {
                isValid = true
            }
        }
    
        return isValid
    }
    
    public func deviceDidStartListeningForIncomingConnections(device: TCDevice)->() {
        print("Started listening for incoming connections")
    }
    
    public func device(device:TCDevice, didStopListeningForIncomingConnections error:NSError)->(){
        print("Stopped listening for incoming connections")
    }
    
    public func device(device:TCDevice, didReceiveIncomingConnection connection:TCConnection)->() {
        print("Receiving an incoming connection")
        self.pendingConnection = connection
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "PendingIncomingConnectionReceived",
            object: nil,
            userInfo:nil)
    }
}