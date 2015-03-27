//
//  Utils.swift
//  SwiftViewTest
//
//  Created by Duncan Champney on 3/26/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import Foundation

/// Function to execute a block after a delay.
/// :param: delay: Double delay in seconds

func delay(delay: Double, block:()->())
{
  let nSecDispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)));
  let queue = dispatch_get_main_queue()
  
  dispatch_after(nSecDispatchTime, queue, block)
}