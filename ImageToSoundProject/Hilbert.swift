//
//  Hilbert.swift
//  FirstSKApp
//
//  Created by Maksym Maisak on 6/14/16.
//  Copyright © 2016 Maksym Maisak. All rights reserved.
//

import Foundation

// PORTED FROM PURE C

// Convert d to (x,y)
func hilbert1Dto2D(n: Int, d: Int) -> (Int, Int) {
    var rx: Int
    var ry: Int
    var t: Int = d
    
    var x = 0
    var y = 0
    
    //for (s = 1; s < n; s *= 2)
    var s = 1
    while(s < n)
    {
        rx = 1 & (t/2);
        ry = 1 & (t ^ rx);
        (x,y) = rot(s, x, y, rx, ry);
        
        x += s * rx;
        y += s * ry;
        
        t /= 4;
        
        s *= 2
    }
    
    return (x, y)
}

//rotate/flip a quadrant appropriately
func rot(n: Int, _ x: Int, _ y: Int, _ rx: Int, _ ry: Int) -> (Int, Int)
{
    var x = x
    var y = y
    
    if (ry == 0)
    {
        if (rx == 1)
        {
            x = n-1 - x;
            y = n-1 - y;
        }
        
        //Swap x and y
        let temp = x;
        x = y;
        y = temp;
        
    }
    
    return (x, y)
}