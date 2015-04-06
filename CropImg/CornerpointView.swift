//
//  CornerpointView.swift
//  CropImg
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//  This class is used to draw the corner points of the user's crop rectangle.

import UIKit

class CornerpointView: UIView
{
  var drawCornerOutlines = false
  var cornerpointDelegate: CornerpointClientProtocol?
  var dragger: UIPanGestureRecognizer!
  var dragStart: CGPoint!
  
  //the centerPoint property is an optional. Set it to nil to hide this corner point.
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
  
  init()
  {
    super.init(frame:CGRectZero)
    self.doSetup()
  }

  required init(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    self.doSetup()
  }
  
  //-------------------------------------------------------------------------------------------------------
  
  func doSetup()
  {
    dragger = UIPanGestureRecognizer(target: self as AnyObject, action: "handleCornerDrag:")
    self.addGestureRecognizer(dragger)

    //Make the corner point view big enough to drag with a finger.
    self.bounds.size = CGSizeMake(30, 30)
    
    //Add a layer to the view to draw an outline for this corner point.
    var newLayer = CALayer()
    newLayer.position = CGPointMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds))
    newLayer.bounds.size = CGSizeMake(7, 7)
    newLayer.borderWidth = 1.0
    newLayer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
    newLayer.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor
    
    
    //This code adds faint outlines around the draggable region of each corner so you can see it.
    //I think it looks better NOT to draw an outline, but the outline does let you know where to drag.
    if drawCornerOutlines
    {
      //Create a faint white 3-point thick rectangle for the draggable area
      var shapeLayer = CAShapeLayer()
      shapeLayer.frame = self.layer.bounds
      shapeLayer.path = UIBezierPath(rect: self.layer.bounds).CGPath
      shapeLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).CGColor
      shapeLayer.lineWidth = 3.0;
      shapeLayer.fillColor = UIColor.clearColor().CGColor
      self.layer.addSublayer(shapeLayer)
      
      //Create a faint black 1 pixel rectangle to go on top  white rectangle
      shapeLayer = CAShapeLayer()
      shapeLayer.frame = self.layer.bounds
      shapeLayer.path = UIBezierPath(rect: self.layer.bounds).CGPath
      shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
      shapeLayer.lineWidth = 1;
      shapeLayer.fillColor = UIColor.clearColor().CGColor
      self.layer.addSublayer(shapeLayer)
      
    }
    self.layer.addSublayer(newLayer)    
    
  }
  
  //-------------------------------------------------------------------------------------------------------
  
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
      
      //If we have a delegate, notify it that this corner has moved.
      //This code uses "optional binding" to convert the optional "cornerpointDelegate" to a required 
      //variable "theDelegate". If cornerpointDelegate == nil, the code that follows is skipped.
      if let theDelegate = cornerpointDelegate
      {
        theDelegate.cornerHasChanged(self)
      }
    default:
      break;
    }
  }
}
