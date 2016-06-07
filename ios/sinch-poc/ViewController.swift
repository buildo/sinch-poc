//
//  ViewController.swift
//  sinch-poc
//
//  Created by Gabriele Petronella on 5/24/16.
//  Copyright © 2016 buildo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SINClientDelegate, SINCallClientDelegate, SINCallDelegate {

  @IBOutlet weak var callerVideoView: UIView!
  @IBOutlet weak var calleeVideoView: UIView!
  
  let caller = "gabro"
  let callee = "dani"
  let sinchClient: SINClient
  var callClient: SINCallClient?
  var call: SINCall?
  var audioPlayer: AVAudioPlayer?
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {

    fatalError("init(coder:) has not been implemented")
  }
  
  required init?(coder aDecoder: NSCoder) {
    sinchClient = Sinch.clientWithApplicationKey("a08df457-78e8-4bd5-bb95-c93ce2d25c1e",
                                                 applicationSecret: "R2Bi1UluMEW3GtyHG7f+Iw==",
                                                 environmentHost: "sandbox.sinch.com",
                                                 userId: caller)
    
    super.init(coder: aDecoder)
    
    sinchClient.setSupportCalling(true)
    sinchClient.setSupportMessaging(true)
    sinchClient.setSupportPushNotifications(true)
    sinchClient.setSupportActiveConnectionInBackground(true)
    sinchClient.enableManagedPushNotifications()
    sinchClient.delegate = self
    sinchClient.callClient().delegate = self
    
    sinchClient.start()

    sinchClient.startListeningOnActiveConnection()
    
    // sinchClient sets the audio session category to PlayAndRecord, which causes all audio to go through
    // the headphone by default
    do {
      // force the audio through the speaker (so that ringtone plays correctly, for instance)
      try! AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  func clientDidFail(client: SINClient!, error: NSError!) {
    NSLog(#function)
    NSLog("%@", error.localizedDescription)
  }
  
  func clientDidStart(client: SINClient!) {
    NSLog(#function)
  }
  

  func client(client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
    NSLog(#function)
    call.delegate = self
    callerVideoView.subviews.first?.removeFromSuperview()
    callerVideoView.addSubview(sinchClient.videoController().localView())
    
    if call.details.applicationStateWhenReceived == .Active {
      let incomingCallVC = storyboard?.instantiateViewControllerWithIdentifier("IncomingCall") as! IncomingCallViewController
      incomingCallVC.call = call
      presentViewController(incomingCallVC, animated: true, completion: nil)
      playIncomingCallSound()
    } else {
      // call came in when the app was in background, so let's answer right away
      call.answer()
    }
  }

  func playIncomingCallSound() {
    let tonePath = NSBundle.mainBundle().pathForResource("incoming-call-single-tone", ofType: "caf")!
    NSLog("%@", tonePath)
    let toneURL = NSURL.fileURLWithPath(tonePath)
    do {
      audioPlayer = try AVAudioPlayer(contentsOfURL: toneURL)
      audioPlayer?.numberOfLoops = -1
      audioPlayer?.play()
    } catch {
      NSLog("%@", (error as NSError).localizedDescription)
    }
  }
  
  func callDidProgress(call: SINCall!) {
    NSLog(#function)
    if (call.state == .Progressing && call.direction == .Outgoing) {
    }
  }
  
  func callDidEstablish(call: SINCall!) {
    NSLog(#function)
    
    // audio through speaker by default
    sinchClient.audioController().enableSpeaker()
    
    // stop ringing
    audioPlayer?.stop()
  }
  
  func callDidAddVideoTrack(call: SINCall!) {
    NSLog(#function)
    calleeVideoView.subviews.first?.removeFromSuperview()
    calleeVideoView.addSubview(sinchClient.videoController().remoteView())
  }
  
  func callDidEnd(call: SINCall!) {
    NSLog(#function)
    calleeVideoView.subviews.first?.removeFromSuperview()
    callerVideoView.subviews.first?.removeFromSuperview()
    audioPlayer?.stop()
  }
  
  func clientDidStop(client: SINClient!) {
    NSLog(#function)
  }
  
  @IBAction func placeCall() {
    NSLog(#function)
    callerVideoView.addSubview(sinchClient.videoController().localView())
    callClient = sinchClient.callClient()
    callClient?.delegate = self
    call = callClient?.callUserVideoWithId(callee)
    call?.delegate = self
//    call?.answer()
    sinchClient.audioController().enableSpeaker()
  }
  
  func client(client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
    let localNotification = SINLocalNotification()
    localNotification.alertAction = "Answer"
    localNotification.alertBody = "📞 Your doctor is calling"
    localNotification.soundName = "incoming-call.caf"
    
    let application = UIApplication.sharedApplication()
    
    var backgroundTaskId: UIBackgroundTaskIdentifier!
    backgroundTaskId = application.beginBackgroundTaskWithExpirationHandler {
      application.endBackgroundTask(backgroundTaskId)
    }
    
    // Schedule 4 ring tones notifications
    for i in 1..<4 {
      delay(Double(i) * 7) {
        
        // Stop scheduling if the app has been launched
        if application.applicationState != .Active {
          NSLog("RIIIIIIIIING")
          
          // Remove all previous notifications
          application.cancelAllLocalNotifications()
          
          let callTone = UILocalNotification()
          callTone.alertAction = "Answer"
          callTone.alertBody = "📞 Your doctor is calling"
          callTone.soundName = "incoming-call-single-tone.caf"
          callTone.fireDate = NSDate()
          
          application.scheduleLocalNotification(callTone)
        }
      }
    }
    
    delay(29) {
      // Remove all previous notifications
      application.cancelAllLocalNotifications()
      
      // Present a missed call notification
      let missedCall = UILocalNotification()
      missedCall.alertBody = "Missed call from your doctor"
      missedCall.alertAction = "call back"
      application.presentLocalNotificationNow(missedCall)
      
      // Terminate just in time
      application.endBackgroundTask(backgroundTaskId)
    }
    
    return localNotification
  }
  
}

