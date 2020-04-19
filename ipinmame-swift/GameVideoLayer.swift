//
//  GameVideoLayer.swift
//  ipinmame-swift
//

import UIKit

class GameVideoLayer: CALayer {
    var bitmapContext: CGContext?
    var pixels: UnsafeMutableRawPointer?
    
    var buffer: UnsafeMutablePointer<UInt8>? {
        get {
            if let pixels = pixels {
                return pixels.assumingMemoryBound(to: UInt8.self)
            }
            return nil
        }
    }
    
    func setup(_ size: CGSize, depth: Int) {
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        if (depth == 32) {
            let bitmapBytesPerRow = Int(size.width * 4);
            
            pixels = UnsafeMutableRawPointer(calloc((bitmapBytesPerRow * Int(size.height)), MemoryLayout<UInt8>.size))
            
            bitmapContext = CGContext(data: pixels,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: bitmapBytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        }
        else {
            let bitmapBytesPerRow = Int(size.width * 2);
            
            pixels = UnsafeMutableRawPointer(calloc((bitmapBytesPerRow * Int(size.height)), MemoryLayout<UInt8>.size))
         
            bitmapContext = CGContext(data: pixels,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 5,
                                      bytesPerRow: bitmapBytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder16Little.rawValue);
        }
    }
    
    override func display() {
        if let bitmapContext = bitmapContext {
            contents = bitmapContext.makeImage()
        }
    }
}
