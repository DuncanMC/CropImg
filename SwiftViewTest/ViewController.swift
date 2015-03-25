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
  if let soundfilePath = theMainBundle.pathForResource(filename,
    ofType: fileType)
  {
    let fileURL = NSURL.fileURLWithPath(soundfilePath)
    return AVAudioPlayer.init(contentsOfURL: fileURL, error: nil)
  }
  else
  {
    return nil
  }
}

//-------------------------------------------------------------------------------------------------------

class ViewController: UIViewController, CropVCProtocol
{

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

  //-------------------------------------------------------------------------------------------------------
  // MARK: - IBAction methods -
  //-------------------------------------------------------------------------------------------------------
  
  @IBAction func handleCropButton(sender: UIButton)
  {
    //println("crop button tapped")
    if let croppedImage = cropView.croppedImage()
    {
      shutterSoundPlayer?.play()
      //Save the cropped image to the user's photo album
      
      UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
      
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
}

