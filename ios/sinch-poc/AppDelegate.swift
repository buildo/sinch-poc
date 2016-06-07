//
//  AppDelegate.swift
//  sinch-poc
//
//  Created by Gabriele Petronella on 5/24/16.
//  Copyright © 2016 buildo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SINManagedPushDelegate {

  var window: UIWindow?
  var push: SINManagedPush?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    push = Sinch.managedPushWithAPSEnvironment(SINAPSEnvironment.Development)
    push?.delegate = self
    push?.setDesiredPushType(SINPushTypeVoIP)
    push?.registerUserNotificationSettings()

    return true
  }
  
  func managedPush(managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [NSObject : AnyObject]!, forType pushType: String!) {
    if let vc = window?.rootViewController as? ViewController {
      vc.sinchClient.relayRemotePushNotification(payload)
    }
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    push?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    push?.application(application, didReceiveRemoteNotification: userInfo)
  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//    if (notification.sin_isSinchNotification()) {
    application.cancelAllLocalNotifications()
    if let vc = window?.rootViewController as? ViewController {
      let result = vc.sinchClient.relayLocalNotification(notification)
      if result.isCall() && result.callResult().isTimedOut {
        // missed call
      }
    }
//    }
  }
}

