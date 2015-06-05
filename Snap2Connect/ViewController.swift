//
//  ViewController.swift
//  Snap2Connect
//
//  Created by Austin Murtha on 5/6/15.
//  Copyright (c) 2015 TechFarm. All rights reserved.
//

import UIKit
import GPUImage


class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, G8TesseractDelegate {

    var filter:GPUImageSobelEdgeDetectionFilter?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(sender: AnyObject) {
        
        //view.endEditing(true)
        //moveViewDown()
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            let cameraButton = UIAlertAction(title: "Take Photo", style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
        imagePickerActionSheet.addAction(cameraButton)
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) -> Void in
        
        }
        
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true, completion: nil)
    }
    

    func useTesseract(img: UIImage, type: TesseractTextType) -> String {
        var tesseract:G8Tesseract = G8Tesseract(language: "ita", configDictionary: [kG8ParamLoadSystemDawg : "F"], configFileNames: nil, cachesRelatedDataPath: nil, engineMode: G8OCREngineMode.TesseractOnly)
        
        switch (type) {
        case .Text:
            //tesseract.charBlacklist = "0123456789/.-_:,;!\"£$%&()=\\?^*§°|qwertyuiopasdfghjklzxcvbnm<>"
            tesseract.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUWXYZÙÒÌÈÀ"
            break
            
        case .TextAndNumbers:
            //tesseract.charBlacklist = "/.-_:,;!\"£$%&()=\\?^*§°|qwertyuiopasdfghjklzxcvbnm<>"
            tesseract.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUWXYZÙÒÌÈÀ0123456789"
            break
            
        case .Date:
            tesseract.charWhitelist = "0123456789/"
            break
            
        default:
            break
        }
        
        tesseract.delegate = self;
        
        let gpuImage = GPUImagePicture(image: img.g8_grayScale())
        
        let luminanceThreshold = GPUImageLuminanceThresholdFilter()
        luminanceThreshold.threshold = 0.290
        let imageFiltered1 = luminanceThreshold.imageByFilteringImage(img.g8_grayScale())
        
        let monoChromo = GPUImageMonochromeFilter()
        monoChromo.color = GPUVector4(one: 0, two: 0, three: 0, four: 1)
        
        let imageFiltered = monoChromo.imageByFilteringImage(imageFiltered1)
        
        tesseract.image = self.thresholdImage(img)
        tesseract.recognize();
        
        println(tesseract.recognizedText)
        return tesseract.recognizedText.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
    
    func thresholdImage(img: UIImage) -> UIImage {
        let luminanceThreshold = GPUImageLuminanceThresholdFilter()
        luminanceThreshold.threshold = 0.305
        let imageFiltered = luminanceThreshold.imageByFilteringImage(img.g8_grayScale())
        return imageFiltered
        
        
    }

    

}



extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
  
        
        
        dismissViewControllerAnimated(true, completion: {
            
            var newPhoto = self.thresholdImage(selectedPhoto)
            self.useTesseract(newPhoto, type: TesseractTextType.TextAndNumbers)
        })
        
    }

}