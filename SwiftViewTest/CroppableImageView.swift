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
  
  var result = CGRectMake(left, top, right-left, bottom-top)
  return result
}

//----------------------------------------------------------------------------------------------------------
class CroppableImageView: UIView, CornerpointClientProtocol
{

  // MARK: - properties -
  var  myImage: UIImage?
  var  imageSize: CGSize?
  var  imageRect: CGRect?
  var aspect: CGFloat
  var draggingRect: Bool = false

  @IBOutlet var  cropDelegate: CropVCProtocol?
//  let myImageView:UIImageView
  let dragger: UIPanGestureRecognizer!
  var cornerpoints =  [CornerpointView]()
  

  var startPoint: CGPoint?
  private var internalCropRect: CGRect?
  var cropRect: CGRect?
    {
    set
    {
      if let realCropRect = newValue
      {
        var newRect:CGRect =  CGRectIntersection(realCropRect, imageRect!)
        internalCropRect = newRect
        cornerpoints[0].centerPoint = newRect.origin
        cornerpoints[1].centerPoint = CGPointMake(CGRectGetMaxX(newRect), newRect.origin.y)
        cornerpoints[3].centerPoint = CGPointMake(newRect.origin.x, CGRectGetMaxY(newRect))
        cornerpoints[2].centerPoint = CGPointMake(CGRectGetMaxX(newRect),CGRectGetMaxY(newRect))
      }
      else
      {
        internalCropRect = nil
        for aCornerpoint in cornerpoints
        {
          aCornerpoint.centerPoint = nil;
        }
      }
      if cropDelegate != nil
      {
        cropDelegate!.haveValidCropRect(internalCropRect != nil && !CGRectIsEmpty(internalCropRect!))
      }
      
      
      self.setNeedsDisplay()
    }
    get
    {
      return internalCropRect
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
//    myImageView = UIImageView(frame: CGRectZero)
    //myImage = UIImage(named: "Scampers 6685")
    myImage = UIImage(named: "Sprite picture (large)")
    imageSize = myImage?.size
    aspect = 1
    
    super.init(coder: aDecoder)
//    myImageView.frame = self.frame
    
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
//    myImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
//    myImageView.contentMode = UIViewContentMode.TopLeft
//    myImageView.layer.borderWidth = 2.0
//    myImageView.layer.borderColor = UIColor.blueColor().CGColor
//    myImageView.image = myImage
  }
  
//---------------------------------------------------------------------------------------------------------
// MARK: - UIView methods
//---------------------------------------------------------------------------------------------------------

  override func awakeFromNib()
  {
    super.awakeFromNib()
//    self.superview?.insertSubview(myImageView, belowSubview: self)

    for aCornerpoint in cornerpoints
    {
      self.addSubview(aCornerpoint)
      aCornerpoint.cornerpointDelegate = self;
    }
    
  /*
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
*/
  }
  
  override func layoutSubviews()
  {
    super.layoutSubviews()
    cropRect = nil;
    
    //If we have an image...
    if let requiredImageSize = imageSize
    {
      var displaySize: CGSize = CGSizeZero
      displaySize.width = min(requiredImageSize.width, self.bounds.size.width)
      displaySize.height = min(requiredImageSize.height, self.bounds.size.height)
      let heightAsepct: CGFloat = displaySize.height/requiredImageSize.height
      let widthAsepct: CGFloat = displaySize.width/requiredImageSize.width
      aspect = min(heightAsepct, widthAsepct)
      displaySize.height = requiredImageSize.height * aspect
      displaySize.width = requiredImageSize.width * aspect
      
      imageRect = CGRectMake(0, 0, displaySize.width, displaySize.height)
    }
  }
  
//---------------------------------------------------------------------------------------------------------
  
 override func drawRect(rect: CGRect)
  {
    myImage?.drawInRect(imageRect!)
    if let realCropRect = internalCropRect
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

  func croppedImage() -> UIImage?
  {
    if var cropRect = internalCropRect
    {
      var drawRect: CGRect = CGRectZero
      drawRect.size = imageSize!
      drawRect.origin.x = round(-cropRect.origin.x / aspect)
      drawRect.origin.y = round(-cropRect.origin.y / aspect)
      cropRect.size.width = round(cropRect.size.width/aspect)
      cropRect.size.height = round(cropRect.size.height/aspect)
      cropRect.origin.x = round(cropRect.origin.x)
      cropRect.origin.y = round(cropRect.origin.y)
      
      UIGraphicsBeginImageContextWithOptions(cropRect.size, true, 1)
      myImage?.drawInRect(drawRect)
      var result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext();
      
      return result
      
    }
    else
    {
      return nil
    }
  }
  
  //---------------------------------------------------------------------------------------------------------
  
  func handleDragInView(thePanner: UIPanGestureRecognizer)
  {
    let newPoint = thePanner.locationInView(self)
    switch thePanner.state
    {
    case UIGestureRecognizerState.Began:
      if internalCropRect != nil && CGRectContainsPoint(internalCropRect!, newPoint)
      {
        startPoint = internalCropRect!.origin
        draggingRect = true;
        thePanner.setTranslation(CGPointZero, inView: self)
      }
      else
      {
      startPoint = newPoint
        draggingRect = false;
      }
      
    case UIGestureRecognizerState.Changed:
      if draggingRect
      {
        var newX = max(startPoint!.x + thePanner.translationInView(self).x,0)
        if newX + internalCropRect!.size.width > imageRect!.size.width
        {
          newX = imageRect!.size.width - internalCropRect!.size.width
        }
        var newY = max(startPoint!.y + thePanner.translationInView(self).y,0)
        if newY + internalCropRect!.size.height > imageRect!.size.height
        {
          newY = imageRect!.size.height - internalCropRect!.size.height
        }
        self.cropRect!.origin = CGPointMake(newX, newY)

      }
      else
      {
        self.cropRect = rectFromStartAndEnd(startPoint!, newPoint)
      }
    default:
      print("")
    }
  }

  func handleViewTap(theTapper: UITapGestureRecognizer)
  {
    self.cropRect = nil
  }
  
  func cornerHasChanged(newCornerPoint: CornerpointView)
  {
    var pointIndex: Int?
    
    
    //Find the cornerpoint the user dragged in the array.
    for (index, aCornerpoint) in enumerate(cornerpoints)
    {
      if newCornerPoint == aCornerpoint
      {
        pointIndex = index
        break
      }
    }
    if (pointIndex == nil)
    {
      return;
    }

    //Find the index of the opposite corner.
    var otherIndex:Int = (pointIndex! + 2) % 4
    
    //Calculate a new cropRect using those 2 corners
    cropRect = rectFromStartAndEnd(newCornerPoint.centerPoint!, cornerpoints[otherIndex].centerPoint!)

    }
  }
