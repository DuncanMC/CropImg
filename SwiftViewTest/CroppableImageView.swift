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
  let viewForImage: UIView
  var  imageSize: CGSize?
  var  imageRect: CGRect?
  var aspect: CGFloat
  var draggingRect: Bool = false

  @IBOutlet var  cropDelegate: CropVCProtocol?
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
        let rectIsTooSmall: Bool = internalCropRect == nil ||
          internalCropRect!.size.width < 5 ||
          internalCropRect!.size.height < 5
        cropDelegate!.haveValidCropRect(internalCropRect != nil && !rectIsTooSmall)
      }
      
      
      self.setNeedsDisplay()
    }
    get
    {
      return internalCropRect
    }

  }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - Designated initializer(s)
  //-------------------------------------------------------------------------------------------------------

   required init(coder aDecoder: NSCoder)
  {
    for i in 1...4
    {
      var aCornerpointView = CornerpointView()
       cornerpoints.append(aCornerpointView)
      //cornerpoints += [CornerpointView()]
    }
    viewForImage = UIView(frame: CGRectZero)
    viewForImage.setTranslatesAutoresizingMaskIntoConstraints(false)
    myImage = UIImage(named: "Curtains 2495")
    imageSize = myImage?.size
    aspect = 1
    
    super.init(coder: aDecoder)
    viewForImage.frame = self.frame;
    dragger = UIPanGestureRecognizer(target: self as AnyObject, action: "handleDragInView:")
    self.addGestureRecognizer(dragger)

    let tapper = UITapGestureRecognizer(target: self as AnyObject,
      action: "handleViewTap:");
    self.addGestureRecognizer(tapper)
    for aCornerpoint in cornerpoints
    {
      tapper.requireGestureRecognizerToFail(aCornerpoint.dragger)
    }
    
  }
  
//---------------------------------------------------------------------------------------------------------
// MARK: - UIView methods
//---------------------------------------------------------------------------------------------------------

  override func awakeFromNib()
  {
    super.awakeFromNib()
       self.superview?.insertSubview(viewForImage, belowSubview: self)


    for aCornerpoint in cornerpoints
    {
      self.addSubview(aCornerpoint)
      aCornerpoint.cornerpointDelegate = self;
    }
    
    //Set up constraints to pin the image-containing view to the edges of this view.
    var aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Top,
      relatedBy: NSLayoutRelation.Equal,
      toItem: viewForImage,
      attribute: NSLayoutAttribute.Top,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Bottom,
      relatedBy: NSLayoutRelation.Equal,
      toItem: viewForImage,
      attribute: NSLayoutAttribute.Bottom,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Left,
      relatedBy: NSLayoutRelation.Equal,
      toItem: viewForImage,
      attribute: NSLayoutAttribute.Left,
      multiplier: 1.0,
      constant: 0)
    self.superview!.addConstraint(aConstraint)
    
    aConstraint = NSLayoutConstraint(item: self,
      attribute: NSLayoutAttribute.Right,
      relatedBy: NSLayoutRelation.Equal,
      toItem: viewForImage,
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
    
    //If we have an image...
    if let requiredImageSize = imageSize
    {
      var displaySize: CGSize = CGSizeZero
      displaySize.width = min(requiredImageSize.width, self.bounds.size.width)
      displaySize.height = min(requiredImageSize.height, self.bounds.size.height)
      let heightAsepct: CGFloat = displaySize.height/requiredImageSize.height
      let widthAsepct: CGFloat = displaySize.width/requiredImageSize.width
      aspect = min(heightAsepct, widthAsepct)
      displaySize.height = round(requiredImageSize.height * aspect)
      displaySize.width = round(requiredImageSize.width * aspect)
      
      imageRect = CGRectMake(0, 0, displaySize.width, displaySize.height)
    }
    
    if myImage != nil
    {
      //Drawing the image every time in drawRect is too slow. Instead, create a 
      //snapshot of the image and install it as the content of the viewForImage's layer
      UIGraphicsBeginImageContextWithOptions(viewForImage.layer.bounds.size, true, 1)
      
      let path = UIBezierPath.init(rect: viewForImage.bounds)
      UIColor.whiteColor().setFill()
      path.fill()

      myImage?.drawInRect(imageRect!)
      var result = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext();
      
      var theImageRef = result!.CGImage
      viewForImage.layer.contents = theImageRef as AnyObject
    }
  }
  
//---------------------------------------------------------------------------------------------------------
  
 override func drawRect(rect: CGRect)
  {
    //Drawing the image in drawRect is too slow. 
    //Switched to installing the image bitmap into a view layer's content
    //myImage?.drawInRect(imageRect!)
    
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
  
  //-------------------------------------------------------------------------------------------------------
  
  func handleDragInView(thePanner: UIPanGestureRecognizer)
  {
    let newPoint = thePanner.locationInView(self)
    switch thePanner.state
    {
    case UIGestureRecognizerState.Began:
      
      //if we have a crop rect and the touch is inside it, drag the entire rect.
      if internalCropRect != nil && CGRectContainsPoint(internalCropRect!, newPoint)
      {
        startPoint = internalCropRect!.origin
        draggingRect = true;
        thePanner.setTranslation(CGPointZero, inView: self)
      }
      else
      {
        //Start definining a new cropRect
        startPoint = newPoint
        draggingRect = false;
      }
      
    case UIGestureRecognizerState.Changed:
      
      //If the user is dragging the entire rect, don't let it be draggged out-of-bounds
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
        //The user is creating a new rect, so just create it from
        //start and end points
        self.cropRect = rectFromStartAndEnd(startPoint!, newPoint)
      }
    default:
      break
    }
  }

  func handleViewTap(theTapper: UITapGestureRecognizer)
  {
    self.cropRect = nil
  }
  
  //-------------------------------------------------------------------------------------------------------
  // MARK: - CornerpointClientProtocol methods
  //-------------------------------------------------------------------------------------------------------
  //This method is called when the user has dragged one of the corners of the crop rectangle
  
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
