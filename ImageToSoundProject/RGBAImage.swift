//
//  RGBAImage.swift
//  ImageToSoundProject
//
//  Created by Maksym Maisak on 6/19/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import Foundation
import UIKit

private func CIImageToCGImage(ciImage: CIImage) -> CGImage! {
    let context = CIContext(options: nil)
    return context.createCGImage(ciImage, fromRect: ciImage.extent)
}


private func UIImageToCGImage(uiImage: UIImage) -> CGImage? {
    
    if let cgImage = uiImage.CGImage {
        return cgImage
    }
    
    if let ciImage = uiImage.CIImage {
        return CIImageToCGImage(ciImage)
    }
    
    return nil
}

struct RGBAImage {
    var pixels: UnsafeMutableBufferPointer<Pixel>
    var width: Int
    var height: Int
    
    subscript(x: Int, y: Int) -> Pixel {
        get {
            precondition(x < width)
            precondition(y < height)
            
            return pixels[y * width + x]
        }
        
        set(newValue) {
            precondition(x < width)
            precondition(y < height)
            
            pixels[y * width + x] = newValue
        }
    }
    
    init?(_ image: UIImage) {
        guard let cgImage = UIImageToCGImage(image) else { return nil }
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<Pixel>.alloc(width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        guard let imageContext = CGBitmapContextCreate(imageData, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else { return nil }
        CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage)
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    func toUIImage() -> UIImage? {
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        let imageContext = CGBitmapContextCreateWithData(pixels.baseAddress, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo, nil, nil)
        guard let cgImage = CGBitmapContextCreateImage(imageContext) else {return nil}
        
        let image = UIImage(CGImage: cgImage)
        return image
    }
}