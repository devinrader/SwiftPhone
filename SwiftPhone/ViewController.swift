//
//  ViewController.swift
//  SwiftPhone
//
//  Created by Devin Rader on 1/28/15.
//  Copyright (c) 2015 Devin Rader. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var phone:Phone!
    
    @IBOutlet weak var answer: UIButton!
    @IBOutlet weak var reject: UIButton!
    @IBOutlet weak var ignore: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.phone = Phone()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:Selector("pendingIncomingConnectionReceived:"),
            name:"PendingIncomingConnectionReceived", object:nil)

        self.phone.login()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func call(sender: AnyObject) {
        self.phone.connectWithParams()
    }
    
    @IBAction func answer(sender: AnyObject) {
        self.phone.acceptConnection()
    }
    
    @IBAction func reject(sender: AnyObject) {
        self.phone.rejectConnection()
    }
    
    @IBAction func ignore(sender: AnyObject) {
        self.phone.ignoreConnection()
    }
    
    @IBAction func sendDigit(sender: AnyObject) {
        self.phone.sendInput(String((sender as! UIButton).tag))
    }
    
    @IBAction func setSpeaker(sender: AnyObject) throws {
        do {
            try self.phone.setSpeaker( (sender as! UISwitch).on )
        } catch let err {
            print(err)
        }
    }

    @IBAction func toggleMute(sender: AnyObject) {
        self.phone.muteConnection( (sender as! UISwitch).on )
    }
    
    func pendingIncomingConnectionReceived(notification:NSNotification) {
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            let notification:UILocalNotification = UILocalNotification()
            notification.alertBody = "Incoming Call"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
        self.answer.enabled = true
        self.reject.enabled = true
        self.ignore.enabled = true
    }

}

