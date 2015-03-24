//
//  ViewController.swift
//  SwiftViewTest
//
//  Created by Duncan Champney on 3/24/15.
//  Copyright (c) 2015 Duncan Champney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CropVCProtocol
{

  @IBOutlet weak var cropButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func handleCropButton(sender: UIButton)
  {
    println("crop button tapped")
  }

  
  func haveValidCropRect(haveValidCropRect:Bool)
  {
    //println("In haveValidCropRect. Value = \(haveValidCropRect)")
    cropButton.enabled = haveValidCropRect
  }
}

