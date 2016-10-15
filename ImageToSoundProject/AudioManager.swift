//
//  AudioManager.swift
//  ImageToSoundProject
//
//  Created by Maksym Maisak on 7/2/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import Foundation
import AudioKit

class AudioManager {
    
    private var oscillator: AKOscillator?
    
    var isPlaying: Bool {
        get {
            return self.oscillator?.isPlaying ?? false
        }
        set {
            if (newValue == true) {
                self.oscillator?.start()
            }
            else {
                self.oscillator?.stop()
            }
        }
    }
    
    var waveform: AKTable? {
        willSet {
            
            AudioKit.stop()
            
            if let strongNewValue = newValue {
                let newOscillator = AKOscillator(waveform: strongNewValue)
                newOscillator.frequency = 1.0
                
                AudioKit.output = newOscillator
                AudioKit.start()
                
                if(self.isPlaying) {
                    newOscillator.start()
                }
                
                self.oscillator = newOscillator
            }
            
        }
    }
    
}