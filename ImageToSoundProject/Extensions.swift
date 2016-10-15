//
//  Extensions.swift
//  ImageToSoundProject
//
//  Created by Maksym Maisak on 6/18/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import UIKit
import AudioKit

extension Double {
    
    func lerp(a: Double, _ b: Double) -> Double {
        return (1-self)*a + self*b
    }
    
}

extension Float {
    
    func lerp(a: Float, _ b: Float) -> Float {
        return (1-self)*a + self*b
    }
    
}

extension UIImage {
    
    func resized(targetSize: CGSize) -> UIImage {
        
        let rect = CGRect(origin: CGPointZero, size: targetSize)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

extension UIView {
    
    func pinToEdgesOf(view: UIView) {
        self.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        self.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        self.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        self.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
}

extension AKOutputWaveformPlot {
    
    static func createSubviewToFitPlaceholder(superview: UIView) -> AKView {
        let width = superview.bounds.width
        let height = superview.bounds.height
        let containerView = AKOutputWaveformPlot.createView(width, height: height)
        
        superview.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.pinToEdgesOf(superview)
        
        let plot = containerView.subviews[0]
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.pinToEdgesOf(containerView)
        
        return containerView
    }
    
}


var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
}