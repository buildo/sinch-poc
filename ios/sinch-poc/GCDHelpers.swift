//
//  GCDHelpers.swift
//  hailadoc-ios
//
//  Created by Gabriele Petronella on 6/17/15.
//  Copyright (c) 2015 buildo. All rights reserved.
//


func delay(delay: Double, handler: () -> Void) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), handler)
}

func updateUI(handler: () -> Void) {
  dispatch_async(dispatch_get_main_queue(), handler)
}