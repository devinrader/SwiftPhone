//
//  Phone.swift
//  SwiftPhone
//
//  Created by Devin Rader on 1/30/15.
//  Copyright (c) 2015 Devin Rader. All rights reserved.
//

import Foundation

let SPDefaultClientName:String = "jenny";
let SPBaseCapabilityTokenUrl:String = "http://example.com/generateToken?%@"
let SPTwiMLAppSid:String = "APxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

public class Phone : NSObject, TCDeviceDelegate {
    var device:TCDevice!
    var connection:TCConnection!
    var pendingConnection:TCConnection!
    
    func login() {
    
        TwilioClient.sharedInstance().setLogLevel(TCLogLevel._LOG_VERBOSE);
        
        var url:String = self.getCapabilityTokenUrl();
        
        var swiftRequest = SwiftRequest();
        swiftRequest.get(url, callback: { (err, response, body) -> () in
            if (err != nil) {
                return;
            }
            
            var token = body as! String
            println(token);
            
            if (err == nil && token != "")
            {
                if ( self.device == nil )
                {
                    self.device = TCDevice(capabilityToken: token as String, delegate: nil);
                }
                else
                {
                    self.device!.updateCapabilityToken(token);
                }
            }
            else if ( err != nil && response != nil) {
                // We received and error with a response
            }
            else if (err != nil) {
                // We received an error without a response
            }
        });
    }
    
    func getCapabilityTokenUrl() -> String {
        
        var querystring:String = String();
        
        querystring += String(format:"&sid=%@", SPTwiMLAppSid);
        querystring += String(format:"&name=%@", SPDefaultClientName);

        return String(format:SPBaseCapabilityTokenUrl, querystring);
    }

    func connectWithParams(params dictParams:Dictionary<String,String> = Dictionary<String,String>()) {
        
        if (!self.capabilityTokenValid())
        {
            self.login();
        }
        
        self.connection = self.device?.connect(dictParams, delegate: nil);
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
        var isValid:Bool = false;
    
        if (self.device != nil) {
            var capabilities = self.device!.capabilities as NSDictionary;
        
            var expirationTimeObject:NSNumber = capabilities.objectForKey("expiration") as! NSNumber;
            var expirationTimeValue:Int64 = expirationTimeObject.longLongValue;
            var currentTimeValue:NSTimeInterval = NSDate().timeIntervalSince1970;
        
            if( (expirationTimeValue-Int64(currentTimeValue)) > 0 ) {
                isValid = true;
            }
        }
    
        return isValid;
    }
    
    public func deviceDidStartListeningForIncomingConnections(device: TCDevice)->() {
        println("Started listening for incoming connections")
    }
    
    public func device(device:TCDevice, didStopListeningForIncomingConnections error:NSError)->(){
        println("Stopped listening for incoming connections")
    }
    
    public func device(device:TCDevice, didReceiveIncomingConnection connection:TCConnection)->() {
        println("Receiving an incoming connection")
        self.pendingConnection = connection
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "PendingIncomingConnectionReceived",
            object: nil,
            userInfo:nil)
    }

}