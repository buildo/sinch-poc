//
//  IncomingCallViewController.swift
//  sinch-poc
//
//  Created by Gabriele Petronella on 5/24/16.
//  Copyright © 2016 buildo. All rights reserved.
//


class IncomingCallViewController: UIViewController {

  var call: SINCall?
  
  @IBAction func declineCall() {
    call?.hangup()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func answerCall() {
    call?.answer()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
