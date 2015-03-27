//
//  ViewController.swift
//  SwiftViewTest
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit
import AVFoundation

//-------------------------------------------------------------------------------------------------------

func loadShutterSoundPlayer() -> AVAudioPlayer?
{
  let theMainBundle = NSBundle.mainBundle()
  let filename = "Shutter sound"
  let fileType = "mp3"
  let soundfilePath: String? = theMainBundle.pathForResource(filename,
    ofType: fileType,
    inDirectory: nil)
  if soundfilePath == nil
  {
    return nil
  }
  //println("soundfilePath = \(soundfilePath)")
  let fileURL = NSURL.fileURLWithPath(soundfilePath!)
  var error: NSError?
  let result: AVAudioPlayer? = AVAudioPlayer.init(contentsOfURL: fileURL, error: &error)
  if let requiredErr = error
  {
    println("AVAudioPlayer.init failed with error \(requiredErr.debugDescription)")
  }
  if let settings = result!.settings
  {
    //println("soundplayer.settings = \(settings)")
  }
  result?.prepareToPlay()
  return result
}

//-------------------------------------------------------------------------------------------------------

class ViewController: UIViewController,
  CropVCProtocol,
  UIImagePickerControllerDelegate,
  UINavigationControllerDelegate,
  UIPopoverControllerDelegate
{
  @IBOutlet weak var whiteView: UIView!
  @IBOutlet weak var cropButton: UIButton!
  @IBOutlet weak var cropView: CroppableImageView!
  
  var shutterSoundPlayer = loadShutterSoundPlayer()
  
override func viewDidLoad()
{
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  enum ImageSource: Int
  {
    case Camera = 1
    case PhotoLibrary
  }
  
  func pickImageFromSource(
    theImageSource: ImageSource,
    fromButton: UIButton)
  {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    switch theImageSource
    {
    case .Camera:
      println("User chose take new pic button")
      imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
      imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front;
    case .PhotoLibrary:
      println("User chose select pic button")
//      imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
      //PhotoLibrary
    }
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad
    {
      if theImageSource == ImageSource.Camera
      {
      self.presentViewController(
        imagePicker,
        animated: true)
        {
        println("In image picker completion block")
        }
      }
      else
      {
        self.presentViewController(
          imagePicker,
          animated: true)
          {
            println("In image picker completion block")
        }
//        //Import from library on iPad
//        let pickPhotoPopover = UIPopoverController.init(contentViewController: imagePicker)
//        //pickPhotoPopover.delegate = self
//        let buttonRect = fromButton.convertRect(
//          fromButton.bounds,
//          toView: self.view.window?.rootViewController?.view)
//        imagePicker.delegate = self;
//        pickPhotoPopover.presentPopoverFromRect(
//          buttonRect,
//          inView: self.view,
//          permittedArrowDirections: UIPopoverArrowDirection.Any,
//          animated: true)
//        
      }
    }
    else
    {
      self.presentViewController(
        imagePicker,
        animated: true)
        {
          println("In image picker completion block")
      }
      
    }
  }
  
  //-------------------------------------------------------------------------------------------------------
  // MARK: - IBAction methods -
  //-------------------------------------------------------------------------------------------------------

  @IBAction func handleSelectImgButton(sender: UIButton)
  {
    println("In \(__FUNCTION__)")
    let anActionSheet = UIAlertController.init(title: "Pick image source",
      message: nil,
      preferredStyle: UIAlertControllerStyle.ActionSheet)

    let sampleAction = UIAlertAction(
      title:"Load Sample Image",
      style: UIAlertActionStyle.Default,
      handler:
      {
        (alert: UIAlertAction!)  in
        self.cropView.imageToCrop = UIImage(named: "Scampers 6685")
      }
      )

    let takePicAction = UIAlertAction(
      title:"Take New Picture",
      style: UIAlertActionStyle.Default,
      handler:
      {
        (alert: UIAlertAction!)  in
        self.pickImageFromSource(
          ImageSource.Camera,
          fromButton: sender)
    }
  )

      let selectPicAction = UIAlertAction(
        title:"Select Picture from library",
        style: UIAlertActionStyle.Default,
        handler:
        {
          (alert: UIAlertAction!)  in
          self.pickImageFromSource(
            ImageSource.PhotoLibrary,
            fromButton: sender)
        }
        )

    let cancelAction = UIAlertAction(
      title:"Cancel",
      style: UIAlertActionStyle.Cancel,
      handler:
      {
        (alert: UIAlertAction!)  in
        println("User chose cancel button")
      }
    )
    anActionSheet.addAction(sampleAction)
    anActionSheet.addAction(takePicAction)
    anActionSheet.addAction(selectPicAction)
    anActionSheet.addAction(cancelAction)
    
    let popover = anActionSheet.popoverPresentationController
    popover?.sourceView = sender
    popover?.sourceRect = sender.bounds;
    
    self.presentViewController(anActionSheet, animated: true)
      {
        //println("In action sheet completion block")
    }
  }
  
  @IBAction func handleCropButton(sender: UIButton)
  {
    if let croppedImage = cropView.croppedImage()
    {
      self.whiteView.hidden = false
      delay(0)
        {
          self.shutterSoundPlayer?.play()
          UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
          
          delay(0.2)
            {
              self.whiteView.hidden = true
              self.shutterSoundPlayer?.prepareToPlay()
          }
      }
      
      
      //The code below saves the cropped image to a file in the user's documents directory.
      /*------------------------
      let jpegData = UIImageJPEGRepresentation(croppedImage, 0.9)
      let documentsPath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
      NSSearchPathDomainMask.UserDomainMask,
      true).last as String
      let filename = "croppedImage.jpg"
      var filePath = documentsPath.stringByAppendingPathComponent(filename)
      if (jpegData.writeToFile(filePath, atomically: true))
      {
      println("Saved image to path \(filePath)")
      }
      else
      {
      println("Error saving file")
      }
      */
    }
  }

  //-------------------------------------------------------------------------------------------------------
  // MARK: - CropVCProtocol methods -
  //-------------------------------------------------------------------------------------------------------

  func haveValidCropRect(haveValidCropRect:Bool)
  {
    //println("In haveValidCropRect. Value = \(haveValidCropRect)")
    cropButton.enabled = haveValidCropRect
  }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - UIImagePickerControllerDelegate methods -
  //-------------------------------------------------------------------------------------------------------
  
  func imagePickerController(
    picker: UIImagePickerController!,
    didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
  {
    println("In \(__FUNCTION__)")
    let image = info[UIImagePickerControllerOriginalImage] as UIImage
    picker.dismissViewControllerAnimated(true, completion: nil)
    cropView.imageToCrop = image
    //cropView.setNeedsLayout()
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController)
  {
    println("In \(__FUNCTION__)")
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

