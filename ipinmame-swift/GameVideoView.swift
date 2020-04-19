//
//  GameVideoView.swift
//  ipinmame-swift
//

import UIKit

class GameVideoView: UIView {
    var size:CGSize!
    var depth: Int!
        
    override class var layerClass: AnyClass {
        get {
            return GameVideoLayer.self
        }
    }
    
    var buffer: UnsafeMutablePointer<UInt8>? {
        get {
            if let layer = layer as? GameVideoLayer {
                return layer.buffer
            }
            return nil
        }
    }
    
    init(frame: CGRect, size: CGSize, depth: Int) {
        super.init(frame: frame)
        
        self.size = size
        self.depth = depth
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        isOpaque = true
        clearsContextBeforeDrawing = false
        isMultipleTouchEnabled = false
        layer.magnificationFilter = .nearest
        
        if let layer = layer as? GameVideoLayer {
            layer.setup(size,
                        depth: depth)
        }
    }
    
    override func draw(_ rect: CGRect) {
    }
}
