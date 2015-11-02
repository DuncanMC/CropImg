//
//  ViewController.swift
//  CropImg
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
    do {
        let result: AVAudioPlayer? = try AVAudioPlayer(contentsOfURL: fileURL)
        result?.prepareToPlay()
        return result
    } catch {
        print("AVAudioPlayer.init failed with error \(error)")
        return nil
    }


}

//-------------------------------------------------------------------------------------------------------

class ViewController:
  UIViewController,
  CroppableImageViewDelegateProtocol,
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
      print("User chose take new pic button")
      imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
      imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front;
    case .PhotoLibrary:
      print("User chose select pic button")
      imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
    }
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad
    {
      if theImageSource == ImageSource.Camera
      {
      self.presentViewController(
        imagePicker,
        animated: true)
        {
          //println("In image picker completion block")
        }
      }
      else
      {
        self.presentViewController(
          imagePicker,
          animated: true)
          {
            //println("In image picker completion block")
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
          print("In image picker completion block")
      }
      
    }
  }
  
  //-------------------------------------------------------------------------------------------------------
  // MARK: - IBAction methods -
  //-------------------------------------------------------------------------------------------------------

  @IBAction func handleSelectImgButton(sender: UIButton)
  {
    /*See if the current device has a camera. (I don't think any device that runs iOS 8 lacks a camera,
    But the simulator doesn't offer a camera, so this prevents the
    "Take a new picture" button from crashing the simulator.
    */
    let deviceHasCamera: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    print("In \(__FUNCTION__)")
    
    //Create an alert controller that asks the user what type of image to choose.
    let anActionSheet = UIAlertController(title: "Pick Image Source",
      message: nil,
      preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    
    //Offer the option to re-load the starting sample image
    let sampleAction = UIAlertAction(
      title:"Load Sample Image",
      style: UIAlertActionStyle.Default,
      handler:
      {
        (alert: UIAlertAction!)  in
        self.cropView.imageToCrop = UIImage(named: "Scampers 6685")
      }
    )
    
    //If the current device has a camera, add a "Take a New Picture" button
    var takePicAction: UIAlertAction? = nil
    if deviceHasCamera
    {
      takePicAction = UIAlertAction(
        title: "Take a New Picture",
        style: UIAlertActionStyle.Default,
        handler:
        {
          (alert: UIAlertAction!)  in
          self.pickImageFromSource(
            ImageSource.Camera,
            fromButton: sender)
        }
      )
    }
    
    //Allow the user to selecxt an amage from their photo library
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
        print("User chose cancel button")
      }
    )
    anActionSheet.addAction(sampleAction)
    
    if let requiredtakePicAction = takePicAction
    {
      anActionSheet.addAction(requiredtakePicAction)
    }
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
  // MARK: - CroppableImageViewDelegateProtocol methods -
  //-------------------------------------------------------------------------------------------------------

  func haveValidCropRect(haveValidCropRect:Bool)
  {
    //println("In haveValidCropRect. Value = \(haveValidCropRect)")
    cropButton.enabled = haveValidCropRect
  }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - UIImagePickerControllerDelegate methods -
  //-------------------------------------------------------------------------------------------------------
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("In \(__FUNCTION__)")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            picker.dismissViewControllerAnimated(true, completion: nil)
            cropView.imageToCrop = image
        }
        //cropView.setNeedsLayout()
    }
    
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController)
  {
    print("In \(__FUNCTION__)")
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

