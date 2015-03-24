//
//  CornerpointView.swift
//  SwiftViewTest
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit

class CornerpointView: UIView
{
  let dragger: UIPanGestureRecognizer!
  var centerPoint: CGPoint?
    {
    didSet(oldPoint)
    {
    
    }
  }
  
  override init()
  {
    super.init(frame:CGRectZero)
    dragger = UIPanGestureRecognizer(target: self as AnyObject, action: "handleCornerDrag:")
    self.addGestureRecognizer(dragger)
   self.doSetup()
  }

  required init(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    dragger = UIPanGestureRecognizer(target: self as AnyObject, action: "handleCornerDrag:")
    self.addGestureRecognizer(dragger)
    self.doSetup()
  }
  
  func doSetup()
  {
    self.layer.borderWidth = 1.0
    self.layer.borderColor = UIColor.blueColor().CGColor
    
  }
  
  func handleCornerDrag(thePanner: UIPanGestureRecognizer)
  {
    println("In cornerpoint dragger")
  }
}
