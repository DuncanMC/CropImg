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
  var  cornerpointDelegate: CornerpointClientProtocol?
  let dragger: UIPanGestureRecognizer!
  var dragStart: CGPoint!
  var centerPoint: CGPoint?
    {
    didSet(oldPoint)
    {
      if let newCenter = centerPoint
      {
        self.hidden = false
        self.center = newCenter
        //println("newCenter = \(newCenter)")
      }
      else
      {
        self.hidden = true
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
    let newPoint = thePanner.locationInView(self)

    switch thePanner.state
    {
    case UIGestureRecognizerState.Began:
      dragStart = centerPoint
      thePanner.setTranslation(CGPointZero,
        inView: self)
      //println("In view dragger began at \(newPoint)")
      
    case UIGestureRecognizerState.Changed:
      //println("In view dragger changed at \(newPoint)")
      centerPoint = CGPointMake(dragStart.x + thePanner.translationInView(self).x,
        dragStart.y + thePanner.translationInView(self).y)
    default:
      print("")
    }
  }
}
