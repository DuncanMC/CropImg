//
//  ViewController.swift
//  CropImg
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

//-------------------------------------------------------------------------------------------------------

func loadShutterSoundPlayer() -> AVAudioPlayer?
{
  let theMainBundle = Bundle.main
  let filename = "Shutter sound"
  let fileType = "mp3"
  let soundfilePath: String? = theMainBundle.path(forResource: filename,
    ofType: fileType,
    inDirectory: nil)
  if soundfilePath == nil
  {
    return nil
  }
  //println("soundfilePath = \(soundfilePath)")
  let fileURL = URL(fileURLWithPath: soundfilePath!)
  var error: NSError?
  let result: AVAudioPlayer?
  do {
    result = try AVAudioPlayer(contentsOf: fileURL)
  } catch let error1 as NSError {
    error = error1
    result = nil
  }
  if let requiredErr = error
  {
    print("AVAudioPlayer.init failed with error \(requiredErr.debugDescription)")
  }
  if result?.settings != nil
  {
    //println("soundplayer.settings = \(settings)")
  }
  result?.prepareToPlay()
  return result
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
  
  override func viewDidAppear(_ animated: Bool) {
    let status = PHPhotoLibrary.authorizationStatus()
    if status != .authorized {
      PHPhotoLibrary.requestAuthorization() {
        status in
      }
    }
  }
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
    case camera = 1
    case photoLibrary
  }
  
  func pickImageFromSource(
    _ theImageSource: ImageSource,
    fromButton: UIButton)
  {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    switch theImageSource
    {
    case .camera:
      print("User chose take new pic button")
      imagePicker.sourceType = UIImagePickerControllerSourceType.camera
      imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front;
    case .photoLibrary:
      print("User chose select pic button")
      imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
    }
    if UIDevice.current.userInterfaceIdiom == .pad
    {
      if theImageSource == ImageSource.camera
      {
      self.present(
        imagePicker,
        animated: true)
        {
          //println("In image picker completion block")
        }
      }
      else
      {
        self.present(
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
      self.present(
        imagePicker,
        animated: true)
        {
          print("In image picker completion block")
      }
      
    }
  }
  
  func saveImageToCameraRoll(_ image: UIImage) {
     PHPhotoLibrary.shared().performChanges({
     PHAssetChangeRequest.creationRequestForAsset(from: image)
     }, completionHandler: { success, error in
     if success {
     // Saved successfully!
     }
     else if let error = error {
      print("Save failed with error " + String(describing: error))
     }
     else {
     }
     })

  }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - IBAction methods -
  //-------------------------------------------------------------------------------------------------------

  @IBAction func handleSelectImgButton(_ sender: UIButton)
  {
    /*See if the current device has a camera. (I don't think any device that runs iOS 8 lacks a camera,
    But the simulator doesn't offer a camera, so this prevents the
    "Take a new picture" button from crashing the simulator.
    */
    let deviceHasCamera: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    print("In \(#function)")
    
    //Create an alert controller that asks the user what type of image to choose.
    let anActionSheet =  UIAlertController(title: "Pick Image Source",
      message: nil,
      preferredStyle: UIAlertControllerStyle.actionSheet)
    
    
    //Offer the option to re-load the starting sample image
    let sampleAction = UIAlertAction(
      title:"Load Sample Image",
      style: UIAlertActionStyle.default,
      handler:
      {
        (alert: UIAlertAction)  in
        self.cropView.imageToCrop = UIImage(named: "Scampers 6685")
      }
    )
    
    //If the current device has a camera, add a "Take a New Picture" button
    var takePicAction: UIAlertAction? = nil
    if deviceHasCamera
    {
      takePicAction = UIAlertAction(
        title: "Take a New Picture",
        style: UIAlertActionStyle.default,
        handler:
        {
          (alert: UIAlertAction)  in
          self.pickImageFromSource(
            ImageSource.camera,
            fromButton: sender)
        }
      )
    }
    
    //Allow the user to selecxt an amage from their photo library
    let selectPicAction = UIAlertAction(
      title:"Select Picture from library",
      style: UIAlertActionStyle.default,
      handler:
      {
        (alert: UIAlertAction)  in
        self.pickImageFromSource(
          ImageSource.photoLibrary,
          fromButton: sender)
      }
    )
    
    let cancelAction = UIAlertAction(
      title:"Cancel",
      style: UIAlertActionStyle.cancel,
      handler:
      {
        (alert: UIAlertAction)  in
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
    
    self.present(anActionSheet, animated: true)
      {
        //println("In action sheet completion block")
    }
  }
  
  
  @IBAction func handleCropButton(_ sender: UIButton)
  {
//    var aFloat: Float
//    aFloat = (sender.currentTitle! as NSString).floatValue
    //println("Button title = \(buttonTitle)")
    if let croppedImage = cropView.croppedImage()
    {
      self.whiteView.isHidden = false
      delay(0)
        {
          self.shutterSoundPlayer?.play()
          self.saveImageToCameraRoll(croppedImage)
          //UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
          
          delay(0.2)
            {
              self.whiteView.isHidden = true
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

  func haveValidCropRect(_ haveValidCropRect:Bool)
  {
    //println("In haveValidCropRect. Value = \(haveValidCropRect)")
    cropButton.isEnabled = haveValidCropRect
  }
  //-------------------------------------------------------------------------------------------------------
  // MARK: - UIImagePickerControllerDelegate methods -
  //-------------------------------------------------------------------------------------------------------
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : Any])
  {
    print("In \(#function)")
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    {
      picker.dismiss(animated: true, completion: nil)
      cropView.imageToCrop = image
    }
    //cropView.setNeedsLayout()
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
  {
    print("In \(#function)")
    picker.dismiss(animated: true, completion: nil)
  }
}

