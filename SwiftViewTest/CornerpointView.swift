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
      if let newCenter = centerPoint
      {
        self.center = newCenter
        //println("newCenter = \(newCenter)")
      }
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
    self.bounds.size = CGSizeMake(30, 30)
    var newLayer = CALayer()
    newLayer.position = CGPointMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds))
    newLayer.bounds.size = CGSizeMake(7, 7)
    newLayer.borderWidth = 1.0
    newLayer.borderColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.5).CGColor
    newLayer.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor
    self.layer.addSublayer(newLayer)
    self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
    self.layer.borderWidth = 1.0
    
  }
  
  func handleCornerDrag(thePanner: UIPanGestureRecognizer)
  {
    //println("In cornerpoint dragger")
  }
}
