//
//  SoundGeneration.swift
//  ImageToSoundProject
//
//  Created by Maksym Maisak on 7/4/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import Foundation
import AudioKit

class SoundGeneration: NSOperation {
    
    private(set) var output: AKTable?
    
    private var imageToConvert: UIImage
    private var parameters: SoundGenerationParameters
    
    init(image: UIImage, parameters inParameters: SoundGenerationParameters) {
        imageToConvert = image
        parameters = inParameters
    }
    
    
    override func main() {
        
        guard (!cancelled) else {return}
        guard let frequencyArray = convertImageToBrightnessArray(imageToConvert) else {return}
        
        guard (!cancelled) else {return}
        guard let waveform = convertFrequencyArrayToWaveform(frequencyArray) else {return}
        
        self.output = waveform
        
        guard (!cancelled) else {return}
    }
    
    func convertImageToBrightnessArray(image: UIImage) -> [Double]? {
        
        guard let rgbaImage = RGBAImage(image) else { fatalError("Could not convert UIImage to RGBAImage") }
        guard rgbaImage.width == rgbaImage.height else {
            let message = "Given image is non-square. Dimensions: (\(rgbaImage.width), \(rgbaImage.height))"
            fatalError(message)
        }
        
        let resolution = rgbaImage.width
        let numberOfPixels = resolution * resolution
        
        guard (!cancelled) else {return nil}
        var brightnessArray = [Double](count: numberOfPixels, repeatedValue: 0.0)
        for i in 0..<numberOfPixels {
            
            let pos2D = hilbert1Dto2D(resolution, d: i)
            let pixel = rgbaImage[pos2D.0, pos2D.1]
            
            let pixelBrightness = (Double(pixel.red) + Double(pixel.green) + Double(pixel.blue)) / (3.0 * 255.0)
            brightnessArray[i] = pixelBrightness
            
            guard (!cancelled) else {return nil}
        }
        
        guard (!cancelled) else {return nil}
        return brightnessArray
    }
    
    private func convertFrequencyArrayToWaveform(frequencyValues: [Double]) -> AKTable? {
        
        let numberOfFrequencies = frequencyValues.count
        
        guard (!cancelled) else {return nil}
        
        // Figure out the frequencies each value corresponds to
        var frequencies = [Double](count: numberOfFrequencies, repeatedValue: 0.0)
        for frequencyNum in 0..<numberOfFrequencies {
            
            let frequencyCoeficient = Double(frequencyNum) / Double(numberOfFrequencies)
            let frequency = frequencyCoeficient.lerp(parameters.lowestFrequency, parameters.highestFrequency)
            
            frequencies[frequencyNum] = round(frequency)
            
            guard (!cancelled) else {return nil}
        }
        
        print("\(numberOfFrequencies) frequencies in range \((parameters.lowestFrequency, parameters.highestFrequency)): \(frequencies)")
        
        // Figure out the amplitudes for each frequency
        var totalAmplitude = 0.0
        var amplitudes = [Double](count: numberOfFrequencies, repeatedValue: 0.0)
        for frequencyNum in 0..<numberOfFrequencies {
            
            let amplitude = frequencyValues[frequencyNum]
            totalAmplitude += amplitude
            amplitudes[frequencyNum] = amplitude
            
            guard (!cancelled) else {return nil}
        }
        
        let numSamples = parameters.numSamples
        var waveform = AKTable(.Sine, size: numSamples)
        for sampleNum in 0..<numSamples {
            
            var value = 0.0
            
            for frequencyNum in 0..<numberOfFrequencies {
                let frequency = frequencies[frequencyNum]
                let amplitude = amplitudes[frequencyNum]
                
                let theta = Double(sampleNum) / Double(numSamples) * 2 * 3.14159265    // from 0 to 2pi
                value += amplitude * sin(frequency * theta)
                
                guard (!cancelled) else {return nil}
            }
            
            waveform.values[sampleNum] = Float(value) / Float(totalAmplitude)
            
            guard (!cancelled) else {return nil}
        }
        
        return waveform
    }
    
}