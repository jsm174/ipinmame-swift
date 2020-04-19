//
//  ViewController.swift
//  ipinmame-swift
//

import UIKit
import PinMAME
import MetalKit

class GameViewController: UIViewController {
    static var sharedInstance: GameViewController!
    
    var videoView: GameVideoView!
    @IBOutlet var keyboardView: KeyboardView!
    @IBOutlet var mtkView: MTKView!
    var renderer: Renderer!
    var rawDmd: UnsafeMutablePointer<UInt8>?
    var texture: MTLTexture?
    
    var bufferShared: MTLBuffer?
    var buffer: MTLBuffer?
    var device: MTLDevice?
    
    var map: Dictionary<UInt8, String>!
    var map2: Dictionary<UInt8, UInt32>!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        GameViewController.sharedInstance = self
        
   
        pinmame_set_log_callback({ format, args in
            if let format = format {
                var log: String?
                
                if let args = args as? CVaListPointer {
                    log = NSString(format: String(cString: format),
                                   arguments: args) as String
                }
                else {
                    log = String(cString: format)
                }
                
                print(log ?? "")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map = [ 0x00: " ",
                0x14: "░",
                0x21: "▒",
                0x43: "▓",
                0x64: "▓" ]
        
        
        map2 = [ 0x00: lerp(r1: 0, g1: 0, b1: 0, r2: 1, g2: 0.18, b2: 0, f: 0),
                 0x14: lerp(r1: 0, g1: 0, b1: 0, r2: 1, g2: 0.18, b2: 0, f: 0.33),
                 0x21: lerp(r1: 0, g1: 0, b1: 0, r2: 1, g2: 0.18, b2: 0, f: 0.66),
                 0x43: lerp(r1: 0, g1: 0, b1: 0, r2: 1, g2: 0.18, b2: 0, f: 1),
                 0x64: lerp(r1: 0, g1: 0, b1: 0, r2: 1, g2: 0.18, b2: 0, f: 1) ]

        mtkView.enableSetNeedsDisplay = true
        device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        renderer = Renderer(view: mtkView)
        renderer.mtkView(mtkView,
                        drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
        
        startup()
    }
        
    func initVideo(_ size: CGSize, depth: Int) -> UnsafeMutablePointer<UInt8>? {
        videoView = GameVideoView(frame: CGRect.zero,
                                  size: size,
                                  depth: depth)
        
        videoView.translatesAutoresizingMaskIntoConstraints = false

        view.insertSubview(videoView, at: 0)
          
        videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        videoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        return videoView.buffer
    }
    
    func startup() {
        if let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .userDomainMask,
                                                              true).first {
            pinmame_set_vpm_path(basePath.cString(using: String.Encoding.utf8))
        }
        
        pinmame_set_keycode_status_callback({ keycode -> Int32  in
            let keyboardKey = GameViewController.sharedInstance.keyboardView.keys[Int(keycode)]
            return keyboardKey.state == .down ? 1 : 0
        })
        
        DispatchQueue.global(qos: .default).async {
            pinmame_start_game("ij_l7", 0)
        }
        
        DispatchQueue.global(qos: .default).async {
            while (true) {
                if pinmame_needs_dmd_update() == 1 {
                    self.displayDmd()
                }
            }
        }
    }
    
    func lerp(r1: Float,
              g1: Float,
              b1: Float,
              r2: Float,
              g2: Float,
              b2: Float,
              f: Float) -> UInt32 {
        let r = r1 + (r2 - r1) * f
        let g = g1 + (g2 - g1) * f
        let b = b1 + (b2 - b1) * f
 
        var v = (UInt32(0xFF) << 24) +
                (UInt32(r * 255) << 16) +
                (UInt32(g * 255) << 8) +
                (UInt32(b * 255))
 
        return v
    }

    
    func displayDmd() {
        let width = pinmame_get_raw_dmd_width();
        let height = pinmame_get_raw_dmd_height();
        
        if (width < 0 || height < 0) {
            return
        }
        
        if rawDmd == nil {
            rawDmd = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(width * height))
        }
     
        if texture == nil {
            bufferShared = device!.makeBuffer(length: Int(width * height) * MemoryLayout<UInt32>.stride,
                                              options: [.storageModeShared])
            
            buffer = device!.makeBuffer(length: Int(width * height) * MemoryLayout<UInt32>.stride,
                                        options: [.storageModeShared])
            
            let textureDescriptor = MTLTextureDescriptor()
            textureDescriptor.pixelFormat = .bgra8Unorm;
            textureDescriptor.storageMode = .shared
            textureDescriptor.width = Int(width)
            textureDescriptor.height = Int(height)

            texture = buffer!.makeTexture(descriptor: textureDescriptor,
                                          offset: 0,
                                          bytesPerRow: 4 * Int(width))
            
            renderer.texture = texture
                 
        }
        print("osd_update_video_and_audio: \(width)x\(height)");
        
        let copied = pinmame_get_raw_dmd_pixels(rawDmd!)
    
        print("copied \(copied)");
        
        for y in 0..<height {
            for x in 0..<width {
                let pixel = rawDmd![Int(y * width + x)]
                 
                print(map[pixel] != nil ? map[pixel]! : " ", terminator: "")
                
                
                let dstPixelIndex = Int(4 * (y * width + x));

                
                
                buffer!.contents().storeBytes(of: map2[pixel]!,
                                              toByteOffset: dstPixelIndex,
                                              as: UInt32.self)
            }
            print("")
        }
        
               
        
        /*if let queue = device!.makeCommandQueue() {
          let commandBuffer = queue.makeCommandBuffer()!
          let bltCmdEncoder = commandBuffer.makeBlitCommandEncoder()!
     
          bltCmdEncoder.copy(from: bufferShared!,
                             sourceOffset: 0,
                             to: buffer!,
                             destinationOffset: 0,
                             size: Int(width * height) * MemoryLayout<UInt32>.size)
          
          bltCmdEncoder.endEncoding()
          
          commandBuffer.addCompletedHandler({ _ in
        
          })
          
          commandBuffer.commit()*/
        
        DispatchQueue.main.async {
            self.mtkView.setNeedsDisplay()
            
        }
            
    }
}

/*
 if (_texture == null) {
     _dmdDimensions = PinMame.GetDmdDimensions();
     _texture = new Texture2D(_dmdDimensions.Width, _dmdDimensions.Height);
     GetComponent<Renderer>().sharedMaterial.mainTexture = _texture;
 }

 var frame = PinMame.GetDmdPixels();
 if (frame.Length == _dmdDimensions.Width * _dmdDimensions.Height) {
     for (var y = 0; y < _dmdDimensions.Height; y++) {
         for (var x = 0; x < _dmdDimensions.Width; x++) {
             var pixel = frame[y * _dmdDimensions.Width + x];
             _texture.SetPixel(x, y, _map.ContainsKey(pixel) ? _map[pixel] : Color.magenta);
         }
     }
 }
 _texture.Apply();
 */
