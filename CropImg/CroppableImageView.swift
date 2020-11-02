//
//  CroppableImageView.swift
//  CropImg
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit

//---------------------------------------------------------------------------------------------------------

func rectFromStartAndEnd(_ startPoint:CGPoint, endPoint: CGPoint) -> CGRect {
    var  top, left, bottom, right: CGFloat;
    top = min(startPoint.y, endPoint.y)
    bottom = max(startPoint.y, endPoint.y)
    
    left = min(startPoint.x, endPoint.x)
    right = max(startPoint.x, endPoint.x)
    
    let result = CGRect(x: left, y: top, width: right-left, height: bottom-top)
    return result
}

//----------------------------------------------------------------------------------------------------------
class CroppableImageView: UIView, CornerpointClientProtocol
{
    // MARK: - properties -
    var  imageToCrop: UIImage? {
        didSet {
            imageSize = imageToCrop?.size
            setNeedsLayout()
        }
    }
    
    let viewForImage: UIView
    var  imageSize: CGSize?
    var  imageRect: CGRect?
    var aspect: CGFloat
    var draggingRect: Bool = false
    
    @IBOutlet var  cropDelegate: CroppableImageViewDelegateProtocol?
    let dragger: UIPanGestureRecognizer
    var cornerpoints =  [CornerpointView]()
    
    
    var startPoint: CGPoint?
    fileprivate var internalCropRect: CGRect?
    var cropRect: CGRect? {
        set {
            if let realCropRect = newValue {
                let newRect:CGRect =  realCropRect.intersection(imageRect!)
                internalCropRect = newRect
                cornerpoints[0].centerPoint = newRect.origin
                cornerpoints[1].centerPoint = CGPoint(x: newRect.maxX, y: newRect.origin.y)
                cornerpoints[3].centerPoint = CGPoint(x: newRect.origin.x, y: newRect.maxY)
                cornerpoints[2].centerPoint = CGPoint(x: newRect.maxX,y: newRect.maxY)
            } else {
                internalCropRect = nil
                for aCornerpoint in cornerpoints {
                    aCornerpoint.centerPoint = nil;
                }
            }
            if let cropDelegate = cropDelegate {
                let rectIsTooSmall: Bool = internalCropRect == nil ||
                    internalCropRect!.size.width < 5 ||
                    internalCropRect!.size.height < 5
                cropDelegate.haveValidCropRect(internalCropRect != nil && !rectIsTooSmall)
            }
            
            
            setNeedsDisplay()
        }
        get {
            return internalCropRect
        }
    }
    
    //-------------------------------------------------------------------------------------------------------
    // MARK: - Designated initializer(s)
    //-------------------------------------------------------------------------------------------------------
    
    required init?(coder aDecoder: NSCoder) {
        for _ in 1...4 {
            let aCornerpointView = CornerpointView()
            cornerpoints.append(aCornerpointView)
            //cornerpoints += [CornerpointView()]
        }
        viewForImage = UIView(frame: CGRect.zero)
        viewForImage.translatesAutoresizingMaskIntoConstraints = false
        aspect = 1
        
        dragger = UIPanGestureRecognizer()
        super.init(coder: aDecoder)
        dragger.addTarget(self as AnyObject, action: #selector(CroppableImageView.handleDragInView(_:)))
        viewForImage.frame = frame;
        addGestureRecognizer(dragger)
        
        let tapper = UITapGestureRecognizer(target: self as AnyObject,
                                            action: #selector(CroppableImageView.handleViewTap(_:)));
        addGestureRecognizer(tapper)
        for aCornerpoint in cornerpoints {
            tapper.require(toFail: aCornerpoint.dragger)
        }
    }
    
    //---------------------------------------------------------------------------------------------------------
    // MARK: - UIView methods
    //---------------------------------------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        superview?.insertSubview(viewForImage, belowSubview: self)
        
        
        for aCornerpoint in cornerpoints {
            addSubview(aCornerpoint)
            aCornerpoint.cornerpointDelegate = self;
        }
        
        //Set up constraints to pin the image-containing view to the edges of this view.
        var aConstraint = NSLayoutConstraint(item: self,
                                             attribute: NSLayoutAttribute.top,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: viewForImage,
                                             attribute: NSLayoutAttribute.top,
                                             multiplier: 1.0,
                                             constant: 0)
        superview!.addConstraint(aConstraint)
        
        aConstraint = NSLayoutConstraint(item: self,
                                         attribute: NSLayoutAttribute.bottom,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: viewForImage,
                                         attribute: NSLayoutAttribute.bottom,
                                         multiplier: 1.0,
                                         constant: 0)
        superview!.addConstraint(aConstraint)
        
        aConstraint = NSLayoutConstraint(item: self,
                                         attribute: NSLayoutAttribute.left,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: viewForImage,
                                         attribute: NSLayoutAttribute.left,
                                         multiplier: 1.0,
                                         constant: 0)
        superview!.addConstraint(aConstraint)
        
        aConstraint = NSLayoutConstraint(item: self,
                                         attribute: NSLayoutAttribute.right,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: viewForImage,
                                         attribute: NSLayoutAttribute.right,
                                         multiplier: 1.0,
                                         constant: 0)
        superview!.addConstraint(aConstraint)
        cropRect = nil;
        
        imageToCrop = UIImage(named: "Scampers 6685")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cropRect = nil;
        
        //If we have an image...
        if let requiredImageSize = imageSize {
            var displaySize: CGSize = CGSize.zero
            displaySize.width = min(requiredImageSize.width, bounds.size.width)
            displaySize.height = min(requiredImageSize.height, bounds.size.height)
            let heightAsepct: CGFloat = displaySize.height/requiredImageSize.height
            let widthAsepct: CGFloat = displaySize.width/requiredImageSize.width
            aspect = min(heightAsepct, widthAsepct)
            displaySize.height = round(requiredImageSize.height * aspect)
            displaySize.width = round(requiredImageSize.width * aspect)
            
            imageRect = CGRect(x: 0, y: 0, width: displaySize.width, height: displaySize.height)
        }
        
        if imageToCrop != nil {
            //Drawing the image every time in drawRect is too slow. Instead, create a 
            //snapshot of the image and install it as the content of the viewForImage's layer
            UIGraphicsBeginImageContextWithOptions(viewForImage.layer.bounds.size, true, 0)
            
            let path = UIBezierPath.init(rect: viewForImage.bounds)
            UIColor.white.setFill()
            path.fill()
            
            imageToCrop?.draw(in: imageRect!)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext();
            
            let theImageRef = result!.cgImage
            viewForImage.layer.contents = theImageRef as AnyObject
        }
    }
    
    //---------------------------------------------------------------------------------------------------------
    
    override func draw(_ rect: CGRect) {
        //Drawing the image in drawRect is too slow. 
        //Switched to installing the image bitmap into a view layer's content
        //myImage?.drawInRect(imageRect!)
        
        if let realCropRect = internalCropRect {
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
    /* 
     Call this method to create new image from the cropped portion of the current image view. It returns nil
     if there is not a valid crop rectangle active.
     */
    func croppedImage() -> UIImage? {
        if var cropRect = internalCropRect {
            var drawRect: CGRect = CGRect.zero
            drawRect.size = imageSize!
            drawRect.origin.x = round(-cropRect.origin.x / aspect)
            drawRect.origin.y = round(-cropRect.origin.y / aspect)
            cropRect.size.width = round(cropRect.size.width/aspect)
            cropRect.size.height = round(cropRect.size.height/aspect)
            cropRect.origin.x = round(cropRect.origin.x)
            cropRect.origin.y = round(cropRect.origin.y)
            
            UIGraphicsBeginImageContextWithOptions(cropRect.size, true, 0)
            imageToCrop?.draw(in: drawRect)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            return result
        } else {
            return nil
        }
    }
    
    //-------------------------------------------------------------------------------------------------------
    
    @objc func handleDragInView(_ thePanner: UIPanGestureRecognizer) {
        let newPoint = thePanner.location(in: self)
        switch thePanner.state {
        case UIGestureRecognizerState.began:
            
            //if we have a crop rect and the touch is inside it, drag the entire rect.
            if let requiredCropRect = internalCropRect {
                if requiredCropRect.contains(newPoint)
                {
                    startPoint = requiredCropRect.origin
                    draggingRect = true;
                    thePanner.setTranslation(CGPoint.zero, in: self)
                }
            }
            if !draggingRect {
                //Start definining a new cropRect
                startPoint = newPoint
                draggingRect = false;
            }
            
        case UIGestureRecognizerState.changed:
            
            //If the user is dragging the entire rect, don't let it be draggged out-of-bounds
            if draggingRect {
                var newX = max(startPoint!.x + thePanner.translation(in: self).x,0)
                if newX + internalCropRect!.size.width > imageRect!.size.width
                {
                    newX = imageRect!.size.width - internalCropRect!.size.width
                }
                var newY = max(startPoint!.y + thePanner.translation(in: self).y,0)
                if newY + internalCropRect!.size.height > imageRect!.size.height
                {
                    newY = imageRect!.size.height - internalCropRect!.size.height
                }
                cropRect!.origin = CGPoint(x: newX, y: newY)
                
            } else {
                //The user is creating a new rect, so just create it from
                //start and end points
                cropRect = rectFromStartAndEnd(startPoint!, endPoint: newPoint)
            }
        default:
            draggingRect = false;
            break
        }
    }
    
    //The user tapped outside of the crop rect. Cancel the current crop rect.
    @objc func handleViewTap(_ theTapper: UITapGestureRecognizer) {
        if imageRect!.contains(theTapper.location(in: self)) {
            cropRect = nil
        }
    }
    
    //-------------------------------------------------------------------------------------------------------
    // MARK: - CornerpointClientProtocol methods
    //-------------------------------------------------------------------------------------------------------
    
    //This method is called when the user has dragged one of the corners of the crop rectangle
    func cornerHasChanged(_ newCornerPoint: CornerpointView) {
        var pointIndex: Int?
        
        //Find the cornerpoint the user dragged in the array.
        for (index, aCornerpoint) in cornerpoints.enumerated() {
            if newCornerPoint == aCornerpoint {
                pointIndex = index
                break
            }
        }
        if (pointIndex == nil) {
            return;
        }
        
        //Find the index of the opposite corner.
        let otherIndex:Int = (pointIndex! + 2) % 4
        
        //Calculate a new cropRect using those 2 corners
        cropRect = rectFromStartAndEnd(newCornerPoint.centerPoint!, endPoint: cornerpoints[otherIndex].centerPoint!)
    }
}
