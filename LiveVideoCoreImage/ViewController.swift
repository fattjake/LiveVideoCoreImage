//
//  ViewController.swift
//  LiveVideoCoreImage
//
//  Created by Jake Gundersen on 7/21/16.
//  Copyright © 2016 Third Rail, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import GLKit

class ViewController: GLKViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var device : AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDispatchQueue = dispatch_queue_create("com.LiveVideo.videoCallback", nil)
    
    var ciContext : CIContext?
    var pause = false

    var outputImage : CIImage?
    
    @IBOutlet weak var doStuffButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let glView = self.view as? GLKView {
            let context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
            glView.context = context
            ciContext = CIContext(EAGLContext: context)
        }
        
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        device = devices.first as? AVCaptureDevice
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
            }
        } catch {
            print("error no input")
        }
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDispatchQueue)
        
        if (captureSession.canAddOutput(videoDataOutput)) {
            captureSession.addOutput(videoDataOutput)
        }
        captureSession.commitConfiguration()

        captureSession.startRunning()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    
        if pause { return }
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let image = CIImage(CVPixelBuffer: videoPixelBuffer)
        if let filter = CIFilter(name: "CICrystallize") {
            filter.setValue(image, forKey: kCIInputImageKey)
            filter.setValue(slider.value, forKey: "inputRadius")
            outputImage = filter.outputImage
        }
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        if let outputImage = outputImage {
            let transformedImage = outputImage.imageByApplyingTransform(CGAffineTransformMakeRotation(CGFloat(-M_PI_2)))
            self.ciContext?.drawImage(transformedImage, inRect: CGRect(x: 0, y:0, width: self.view.frame.size.width * 2.0, height: self.view.frame.size.height * 2.0), fromRect: transformedImage.extent)
        }
    }
    
    @IBAction func doStuffButtonPressed(sender: AnyObject) {
        //Change torch mode
        do {
            try device?.lockForConfiguration()
            guard let torchMode = device?.torchMode else { return }
            let newTorchModeInt = (torchMode.hashValue + 1) % 3
            guard let newTorchMode = AVCaptureTorchMode(rawValue: newTorchModeInt) else { return }
            device?.torchMode = newTorchMode
            device?.unlockForConfiguration()
        } catch {
            print("Error locking device")
        }
    }
}

