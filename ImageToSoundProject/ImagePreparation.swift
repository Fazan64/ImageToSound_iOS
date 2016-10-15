//
//  ImagePreparation.swift
//  ImageToSoundProject
//
//  Created by Maksym Maisak on 7/4/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import Foundation
import UIKit

class ImagePreparation: NSOperation {
    
    private(set) var output: UIImage?
    
    private var origianlImage: UIImage
    private var resolution: Int
    
    init(image: UIImage, resolution inResolution: Int) {
        origianlImage = image
        resolution = inResolution
    }
    
    override func main() {
        
        guard (!cancelled) else {return}
        output = prepareImage(origianlImage)
        guard (!cancelled) else {return}
        
    }
    
    
    private func prepareImage(image: UIImage) -> UIImage? {
        
        let initialImage = CIImage(image: image)
        
        guard (!cancelled) else {return nil}
        
        let filterName = "CIColorMonochrome"
        guard let filter = CIFilter(name: filterName) else {fatalError("Could not create CIFilter. Invalid filter name?")}
        
        guard (!cancelled) else {return nil}

        let inputColor = CIColor(color: UIColor.grayColor())
        
        filter.setValue(inputColor, forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")
        filter.setValue(initialImage, forKey: "inputImage")
        
        guard (!cancelled) else {return nil}
        guard let outputImage = filter.outputImage else {fatalError("filter.outputImage is nil for some reason")}
        
        guard (!cancelled) else {return nil}
        let filtered = UIImage(CIImage: outputImage)
        
        guard (!cancelled) else {return nil}
        let resized = filtered.resized(CGSize(width: resolution, height: resolution))
        
        guard (!cancelled) else {return nil}
        
        return resized


    }
    
}