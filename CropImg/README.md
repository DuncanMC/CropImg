##CropImg
-----

A sample application for cropping images, written in Swift.


###The `CropppableImageView` class:

The main class is the `CropppableImageView` class, which is a subclass of UIView.

To use a `CroppableImageView` in your project, drag a UIView into your XIB/storyboard. Then use the "Idenity Inspector" to change the type to CroppableImageView.

If you need to be notified if there is a valid crop area defined, set up a delegate object that conforms to the CroppableImageViewDelegateProtocol. That protocol only has 1 method, `haveValidCropRect()`. The `CroppableImageView` will call your `haveValidCropRect()` method when the user selects/deselects a crop rectangle. You can use the `haveValidCropRect()` method to enable/disable a crop button, for example.

The `CropppableImageView` has a method `croppedImage()` that returns a new image containing the portion of the source image the user has selected, or nil if the selection rectangle isn't valid.

###The `CornerpointView` class:

The `CropppableImageView` class uses another class, `CornerpointView`, to draw the cornerpoints of the image view, and allow dragging of the cornerpoints. A `CropppableImageView` sets up 4 `CornerpointView` objects and adds them as subviews in it's init method.

The initalizers for `CornerpointView` create pan gesture recognziers and connect them to the view so  `CornerpointView` objects are automatically draggable. 
The `CornerpointView`s `centerPoint` property is optional and is initially nil. The `centerPoint` property has a didSet method that hides the `CornerpointView` if the centerPoint is nil and un-hides the corner point if the `centerPoint` is *not* nil.

The `CornerpointView` class has an optional `cornerpointDelegate` property. (If you set a conerpointDelegate, it must conform to the `CornerpointClientProtocol`.) The `CropppableImageView` sets itself up as the delegate of it's `CornerpointView`s.


The only method in the `CornerpointClientProtocol` is cornerHasChanged. It simply tells the delegate that the user has moved the corner point. It passes a pointer to itself so the delegate can tell which corner has changed.

###The `ViewController` class:

The 'ViewController` class coordinates between the `CropppableImageView` and the button that triggers image cropping.

The 'ViewController` class also offers a button to load a new image into the image view. 

Loading a new image is handled by the `handleSelectImgButton` `IBAction` method. This method uses the new `UIAlertController` class, added in iOS 8 instead of the now-deprecated `UIAlertView`. (Note that if you want your app to run under iOS 7 and 8, you will still have to use a UIAlertView, or write code that uses a UIAlertView on iOS 7 and a `UIAlertController` under iOS 8) 

A `UIAlertController` uses a modern block-based design pattern, where you create one or more `UIAlertAction` objects and attach them to the `UIAlertController`. These `UIAlertAction` objects are usually drawn as buttons, and inlcude a block of code that's executed when the user chooses that option.

The "Take a New Picture" action and the "Select Picture from library" action both call the method `pickImageFromSource`. This method creates and displays a `UIImagePickerController`. The docs for `UIImagePickerController` say that you must use a popover to display the picker controller in a popover on iPad for anything but taking a picture with the camera. However, I've found that displaying a full-screen picker works on iPad, and it gives the user more room to navigate their photo library.

The crop button on the view controller's view is linked to the `handleCropButton()` IBAction method. The `handleCropButton()` method calls the `CropppableImageView`s `croppedImage()` mehod to create a croppped image. It then plays a shutter sound, displays a white view on top of the image to simulate a flash of light, then finally calls the Cocoa Touch method `UIImageWriteToSavedPhotosAlbum` to save the cropped image to the user's photo album. 

There is code at the bottom of the `handleCropButton()` method that will save the cropped image to the user's documents directory instead, in case that's what you need to do in your app.