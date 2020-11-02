//
//  Utils.swift
//  CropImg
//
//  Created by Duncan Champney on 3/26/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import Foundation

/// Function to execute a block after a delay.
/// - parameter delay:: Double delay in seconds

func delay(_ delay: Double, block:@escaping ()->()) {
    let nSecDispatchTime = DispatchTime.now() + delay;
    let queue = DispatchQueue.main
    queue.asyncAfter(deadline: nSecDispatchTime, execute: block)
}
