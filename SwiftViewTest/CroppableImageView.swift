//
//  CroppableImageView.swift
//  SwiftViewTest
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit

//-----------------------------------------------------------------------------------------------------------

func rectFromStartAndEnd(var startPoint:CGPoint, endPoint: CGPoint) -> CGRect
{
  var  top, left, bottom, right: CGFloat;
  top = min(startPoint.y, endPoint.y)
  bottom = max(startPoint.y, endPoint.y)
  
  left = min(startPoint.x, endPoint.x)
  right = max(startPoint.x, endPoint.x)
  
  
  return CGRectMake(left, top, right-left, bottom-top)
}

//-----------------------------------------------------------------------------------------------------------
class CroppableImageView: UIView
{
  let myImageView:UIImageView
  let dragger: UIPanGestureRecognizer!
  let cornerpoints =  [CornerpointView](count: 4, repeatedValue: CornerpointView())

  var startPoint: CGPoint?
  var cropRect: CGRect?
    {
    didSet(oldRect)
    {
      if cropRect != oldRect
      {
        println("rect changed to \(cropRect)")
        if cropRect == nil
        {
          for aCornerpoint in cornerpoints
          {
            aCornerpoint.centerPoint = nil;
          }
        }
        else
        {
          cornerpoints[0].centerPoint = cropRect!.origin
          cornerpoints[1].centerPoint = CGPointMake(CGRectGetMaxX(cropRect!), cropRect!.origin.y)
          cornerpoints[2].centerPoint = CGPointMake(cropRect!.origin.x, CGRectGetMaxY(cropRect!))
          cornerpoints[3].centerPoint = CGPointMake(CGRectGetMaxX(cropRect!),CGRectGetMaxY(cropRect!))
        }
      }
    }
  }
  required init(coder aDecoder: NSCoder)
  {
    
    //Add an imageview as a child of this view
    myImageView = UIImageView(frame: CGRectZero)
    super.init(coder: aDecoder)
    myImageView.frame = self.bounds
    self.addSubview(myImageView)
    
    dragger = UIPanGestureRecognizer(target: self as AnyObject, action: "handleDragInView:")
    self.addGestureRecognizer(dragger)

    //Set up constraints to pin the image view to the edges of this view.
    var aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Top,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Top,
      multiplier: 1.0,
      constant: 0)
    self.addConstraint(aConstraint)

    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Bottom,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Bottom,
      multiplier: 1.0,
      constant: 0)
    self.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Left,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Left,
      multiplier: 1.0,
      constant: 0)
    self.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Right,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Right,
      multiplier: 1.0,
      constant: 0)
    self.addConstraint(aConstraint)
    
    //Install a test image into the image view.
    let myImage = UIImage(named: "Scampers 6685")
    myImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    myImageView.contentMode = UIViewContentMode.ScaleAspectFit
    myImageView.layer.borderWidth = 2.0
    myImageView.layer.borderColor = UIColor.blueColor().CGColor
    myImageView.image = myImage
  }
  
  //-----------------------------------------------------------------------------------------------------------
  func handleDragInView(thePanner: UIPanGestureRecognizer)
  {
    let newPoint = thePanner.locationInView(self)
    switch thePanner.state
    {
    case UIGestureRecognizerState.Began:
      startPoint = newPoint
      println("In view dragger began at \(newPoint)")
      
    case UIGestureRecognizerState.Changed:
      println("In view dragger changed at \(newPoint)")
      self.cropRect = rectFromStartAndEnd(startPoint!, newPoint)
    default:
      print("")
    }
  }

  
}
