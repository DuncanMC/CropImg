//
//  CroppableImageView.swift
//  SwiftViewTest
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit

//---------------------------------------------------------------------------------------------------------

func rectFromStartAndEnd(var startPoint:CGPoint, endPoint: CGPoint) -> CGRect
{
  var  top, left, bottom, right: CGFloat;
  top = min(startPoint.y, endPoint.y)
  bottom = max(startPoint.y, endPoint.y)
  
  left = min(startPoint.x, endPoint.x)
  right = max(startPoint.x, endPoint.x)
  
  
  return CGRectMake(left, top, right-left, bottom-top)
}

//----------------------------------------------------------------------------------------------------------
class CroppableImageView: UIView, CornerpointClientProtocol
{

  // MARK: - properties -
  @IBOutlet var  cropDelegate: CropVCProtocol?
  let myImageView:UIImageView
  let dragger: UIPanGestureRecognizer!
  var cornerpoints =  [CornerpointView]()
  

  var startPoint: CGPoint?
  var cropRect: CGRect?
    {
    didSet(oldRect)
    {
      //println("rect changed to \(cropRect)")
      if let realCropRect = cropRect
      {
        //println("Croprect = \(cropRect!). Setting cornerpoints")
        cornerpoints[0].centerPoint = realCropRect.origin
        cornerpoints[1].centerPoint = CGPointMake(CGRectGetMaxX(realCropRect), realCropRect.origin.y)
        cornerpoints[2].centerPoint = CGPointMake(realCropRect.origin.x, CGRectGetMaxY(realCropRect))
        cornerpoints[3].centerPoint = CGPointMake(CGRectGetMaxX(realCropRect),CGRectGetMaxY(realCropRect))
      }
      else
      {
        for aCornerpoint in cornerpoints
        {
          aCornerpoint.centerPoint = nil;
        }
      }
      if cropDelegate != nil
      {
        cropDelegate!.haveValidCropRect(cropRect != nil)
      }
      
      
      self.setNeedsDisplay()
    }
  }
  //---------------------------------------------------------------------------------------------------------
  // MARK: - Designated initializer(s)
  //---------------------------------------------------------------------------------------------------------

  required init(coder aDecoder: NSCoder)
  {
    for i in 1...4
    {
      var aCornerpointView = CornerpointView()
       cornerpoints.append(aCornerpointView)
      //cornerpoints += [CornerpointView()]
    }

    //Add an imageview as a child of this view
    myImageView = UIImageView(frame: CGRectZero)
    super.init(coder: aDecoder)
    myImageView.frame = self.frame
    
    //myImageView.hidden = true
    dragger = UIPanGestureRecognizer(target: self as AnyObject, action: "handleDragInView:")
    self.addGestureRecognizer(dragger)

    let tapper = UITapGestureRecognizer(target: self as AnyObject,
      action: "handleViewTap:");
    self.addGestureRecognizer(tapper)
    for aCornerpoint in cornerpoints
    {
      tapper.requireGestureRecognizerToFail(aCornerpoint.dragger)
    }
    
    //Install a test image into the image view.
    let myImage = UIImage(named: "Scampers 6685")
    myImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    myImageView.contentMode = UIViewContentMode.ScaleAspectFit
//    myImageView.layer.borderWidth = 2.0
//    myImageView.layer.borderColor = UIColor.blueColor().CGColor
    myImageView.image = myImage
  }
  
//---------------------------------------------------------------------------------------------------------
// MARK: - UIView methods
//---------------------------------------------------------------------------------------------------------

  override func awakeFromNib()
  {
    super.awakeFromNib()
    self.superview?.insertSubview(myImageView, belowSubview: self)

    for aCornerpoint in cornerpoints
    {
      self.addSubview(aCornerpoint)
      aCornerpoint.cornerpointDelegate = self;
    }
    
    //Set up constraints to pin the image view to the edges of this view.
    var aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Top,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Top,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Bottom,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Bottom,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Left,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Left,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Right,
      relatedBy: NSLayoutRelation.Equal,
      toItem: myImageView,
      attribute: NSLayoutAttribute.Right,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    cropRect = nil;
  }
  
  override func layoutSubviews()
  {
    super.layoutSubviews()
    cropRect = nil;
  }
  
//---------------------------------------------------------------------------------------------------------
  
 override func drawRect(rect: CGRect)
  {
    if let realCropRect = cropRect
    {
      let path = UIBezierPath(rect: realCropRect)
      path.lineWidth = 3.0
      UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).set()
      path.stroke()
      path.lineWidth = 1.0
      UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).set()
      path.stroke()
    }
  }

//---------------------------------------------------------------------------------------------------------
// MARK: - custom instance methods -
//---------------------------------------------------------------------------------------------------------

  
  func handleDragInView(thePanner: UIPanGestureRecognizer)
  {
    let newPoint = thePanner.locationInView(self)
    switch thePanner.state
    {
    case UIGestureRecognizerState.Began:
      startPoint = newPoint
      //println("In view dragger began at \(newPoint)")
      
    case UIGestureRecognizerState.Changed:
      //println("In view dragger changed at \(newPoint)")
      self.cropRect = CGRectIntersection(self.bounds,rectFromStartAndEnd(startPoint!, newPoint))
    default:
      print("")
    }
  }

  func handleViewTap(theTapper: UITapGestureRecognizer)
  {
    self.cropRect = nil
  }
  
  func cornerHasChanged(CornerpointView)
  {
    println("In cornerHasChanged")
  }
}
