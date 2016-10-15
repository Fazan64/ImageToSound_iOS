//
//  ViewController.swift
//  ImageToSoundProject
//
//  Created by Maksym Maisak on 6/18/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageOneView: UIImageView!
    @IBOutlet weak var imageTwoView: UIImageView!
    
    @IBOutlet weak var preparingImageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var generatingSoundIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var audioPlotView: UIView!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var resolutionLabel: UILabel!
    @IBOutlet weak var resolutionStepper: UIStepper!
    
    private var imageResolution = 2 {
        didSet {
            setupCurrentImagePreparationOperation()
        }
    }
    
    private var audioManager = AudioManager()
    lazy private var imagePicker = UIImagePickerController()
    
    //MARK: concurrency stuff
    
    lazy private var concurrentOperationQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "ViewController's concurrent operation queue"
        return queue
    }()
    
    private var currentImagePreparation: ImagePreparation?
    private var currentSoundGeneration: SoundGeneration?
    //MARK: concurrency stuff end
    
    private var userSelectedImage: UIImage? {
        willSet(newImage) {
            guard let newImage = newImage else {return}
            imageOneView.image = newImage
        }
        didSet {
            guard userSelectedImage != nil else {return}
            setupCurrentImagePreparationOperation()
        }
    }
    
    private var imageToConvert: UIImage? {
        willSet {
            if (newValue != nil) {
                self.imageTwoView.image = newValue
            }
        }
    }
    
    private var soundGenerationParameters: SoundGenerationParameters {
        get {
            let numberOfSamples = 1024 * 64
            let lowestFrequency = 16.0
            let highestFrequency = lowestFrequency + lowestFrequency * 1024.0
            
            let params = SoundGenerationParameters(
                numSamples: numberOfSamples,
                lowestFrequency: lowestFrequency,
                highestFrequency: highestFrequency)
            
            return params
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        setupAKOutputWaveformPlot()
        
        if let image = imageOneView.image {
            userSelectedImage = image
        }
        
        imageTwoView.layer.magnificationFilter = kCAFilterNearest
        
        updateResolutionLabel()
    }
    
    //MARK: image selection
    
    @IBAction func selectNewImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userSelectedImage = pickedImage
        }
        
    }
    //MARK: image selection end
    
    @IBAction func returnFromAboutPage(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func resolutionStepperValueChanged(sender: UIStepper) {
        let power = sender.value
        let value = Int(pow(2, power))
        
        self.imageResolution = value
        updateResolutionLabel()
    }
    
    private func updateResolutionLabel() {
        resolutionLabel.text = String(self.imageResolution)
    }
    
    @IBAction func startStopButtonTapped(sender: UIButton) {
        
        let audioIsPlaying = self.audioManager.isPlaying
        
        if(audioIsPlaying) {
            startStopButton.setTitle("Play", forState: UIControlState.Normal)
            self.audioManager.isPlaying = false
        }
        else {
            startStopButton.setTitle("Stop", forState: UIControlState.Normal)
            self.audioManager.isPlaying = true
        }
    }
    
    private func setupAKOutputWaveformPlot() {
        AKOutputWaveformPlot.createSubviewToFitPlaceholder(audioPlotView)
    }
    
    private func setupCurrentImagePreparationOperation() {
        
        guard let imageToPrepare = userSelectedImage else { return }
        
        currentImagePreparation?.cancel()
        
        preparingImageIndicator.startAnimating()
        
        let preparationOperation = ImagePreparation(image: imageToPrepare, resolution: imageResolution)
        preparationOperation.completionBlock = {
            
            guard (!preparationOperation.cancelled) else {
                NSLog("ImagePreparation operation aborted")
                return
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                let preparedImage = preparationOperation.output
                self.imageToConvert = preparedImage
                self.preparingImageIndicator.stopAnimating()
                self.setupSoundGenerationOperation()
            }
        }
        
        currentImagePreparation = preparationOperation
        concurrentOperationQueue.addOperation(preparationOperation)
    }
    
    private func setupSoundGenerationOperation() {
        
        guard let imageToConvert = imageToConvert else {return}
        
        currentSoundGeneration?.cancel()
        
        generatingSoundIndicator.startAnimating()
        
        let parameters = self.soundGenerationParameters
        let generationOperation = SoundGeneration(image: imageToConvert, parameters: parameters)
        generationOperation.completionBlock = {
            
            guard (!generationOperation.cancelled) else {
                NSLog("SoundGeneration operation aborted")
                return
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.audioManager.waveform = generationOperation.output
                self.generatingSoundIndicator.stopAnimating()
                self.startStopButton.enabled = true
            }
        }
        
        currentSoundGeneration = generationOperation
        concurrentOperationQueue.addOperation(generationOperation)
    }

}