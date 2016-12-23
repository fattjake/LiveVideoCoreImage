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

extension CGRect {
    var center : CGPoint {
        get {
            return CGPoint(x: origin.x + size.width / 2.0, y: origin.y + size.height / 2.0)
        }
    }
}

class ViewController: GLKViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var device : AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDispatchQueue = DispatchQueue(label: "com.LiveVideo.videoCallback", attributes: [])
    
    var ciContext : CIContext?
    var pause = false

    var outputImage : CIImage?
    
    @IBOutlet weak var doStuffButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let glView = self.view as? GLKView {
            let context = EAGLContext(api: EAGLRenderingAPI.openGLES2)
            glView.context = context!
            ciContext = CIContext(eaglContext: context!)
        }
        
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices().filter{ ($0 as AnyObject).hasMediaType(AVMediaTypeVideo) && ($0 as AnyObject).position == AVCaptureDevicePosition.back }
        device = devices.first as? AVCaptureDevice
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
            }
        } catch {
            print("error no input")
        }

//        let previewLayer = AVCaptureVideoPreviewLayer()
//        previewLayer.bounds = view.bounds
//        previewLayer.position = view.frame.center
//        
//        view.layer.addSublayer(previewLayer)
//        previewLayer.session = captureSession
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

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
        if pause { return }
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let image = CIImage(cvPixelBuffer: videoPixelBuffer)
        
//        ciContext?.draw(image, in: view.bounds, from: image.extent)
        
        if let filter = CIFilter(name: "CICrystallize") {
            filter.setValue(image, forKey: kCIInputImageKey)
            filter.setValue(slider.value, forKey: "inputRadius")
            outputImage = filter.outputImage
        }
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        if let outputImage = outputImage {
            let transformedImage = outputImage.applying(CGAffineTransform(rotationAngle: CGFloat(-M_PI_2)))
            let scale = UIScreen.main.scale
            self.ciContext?.draw(transformedImage, in: CGRect(x: 0, y:0, width: self.view.frame.size.width * scale, height: self.view.frame.size.height * scale), from: transformedImage.extent)
        }
    }
    
    @IBAction func doStuffButtonPressed(_ sender: AnyObject) {
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

