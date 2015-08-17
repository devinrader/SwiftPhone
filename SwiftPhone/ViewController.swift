//
//  ViewController.swift
//  SwiftPhone
//
//  Created by Devin Rader on 1/28/15.
//  Copyright (c) 2015 Devin Rader. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var phone:Phone = Phone();
    
    @IBOutlet weak var btnAnswer: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnIgnore: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:Selector("pendingIncomingConnectionReceived:"),
            name:"PendingIncomingConnectionReceived", object:nil)

        self.phone.login();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnCall(sender: AnyObject) {
        self.phone.connectWithParams();
    }
    
    @IBAction func btnAnswer(sender: AnyObject) {
        self.phone.acceptConnection()
    }
    
    @IBAction func btnReject(sender: AnyObject) {
        self.phone.rejectConnection()
    }
    
    @IBAction func btnIgnore(sender: AnyObject) {
        self.phone.ignoreConnection()
    }
    
    func pendingIncomingConnectionReceived(notification:NSNotification) {
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            var notification:UILocalNotification = UILocalNotification()
            notification.alertBody = "Incoming Call"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
        self.btnAnswer.enabled = true
        self.btnReject.enabled = true
        self.btnIgnore.enabled = true
    }

}

