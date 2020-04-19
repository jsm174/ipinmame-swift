//
//  KeyboardView.swift
//  ipinmame-swift
//

import UIKit

struct Matrix {
    let rows: Int, columns: Int
    var grid: [Int]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Int {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

enum Keystate: Int {
    case up = 0
    case down
}

struct KeyboardKey {
    var rect: CGRect!
    var state: Keystate!
}

struct KeyboardTouch {
    var touch: UITouch!
    var keycode: Int!
}

class KeyboardView: UIView {
    var keyboardImage: UIImage!
    var keyboardPressedImage: UIImage!
    
    var keys = [KeyboardKey]()
    var hitMatrix: Matrix!
    
    
    var keyTouches = [KeyboardTouch]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        common_init()
    }
    
    func common_init() {
        backgroundColor = .clear
        
        keyboardImage = UIImage(named: "keyboard")
        keyboardPressedImage = UIImage(named: "keyboard-pressed")
        
        hitMatrix = Matrix(rows: 257, columns: 1005)
        
        [
            [   0,   0,   0,   0 ], //
            [   1,   0,  42,  26 ], //   1 - ESC
            [  47,   0,  42,  26 ], //   2 - F1
            [  94,   0,  42,  26 ], //   3 - F2
            [ 141,   0,  42,  26 ], //   4 - F3
            [ 188,   0,  42,  26 ], //   5 - F4
            [ 235,   0,  42,  26 ], //   6 - F5
            [ 282,   0,  42,  26 ], //   7 - F6
            [ 328,   0,  42,  26 ], //   8 - F7
            [ 375,   0,  42,  26 ], //   9 - F8
            [ 422,   0,  42,  26 ], //  10 - F9
            [ 469,   0,  42,  26 ], //  11 - F10
            [ 516,   0,  42,  26 ], //  12 - F11
            [ 562,   0,  42,  26 ], //  13 - F12
            [ 609,   0,  42,  26 ], //  14 - EJECT
            
            [ 672,   0,  42,  26 ], //  15 - F13
            [ 718,   0,  42,  26 ], //  16 - F14
            [ 765,   0,  42,  26 ], //  17 - F15
            
            [ 827,   0,  42,  26 ], //  18 - F16
            [ 872,   0,  42,  26 ], //  19 - F17
            [ 917,   0,  42,  26 ], //  20 - F18
            [ 962,   0,  42,  26 ], //  21 - F19
            
            [   0,  32,  41,  39 ], //  22 - ~
            [  45,  32,  41,  39 ], //  23 - 1
            [  90,  32,  41,  39 ], //  24 - 2
            [ 136,  32,  41,  39 ], //  25 - 3
            [ 181,  32,  41,  39 ], //  26 - 4
            [ 226,  32,  41,  39 ], //  27 - 5
            [ 272,  32,  41,  39 ], //  28 - 6
            [ 317,  32,  41,  39 ], //  29 - 7
            [ 362,  32,  41,  39 ], //  30 - 8
            [ 408,  32,  41,  39 ], //  31 - 9
            [ 453,  32,  41,  39 ], //  32 - 0
            [ 498,  32,  41,  39 ], //  33 - -
            [ 544,  32,  41,  39 ], //  34 - =
            [ 587,  32,  64,  39 ], //  35 - DEL
            
            [ 673,  32,  41,  39 ], //  36 - FN
            [ 718,  32,  41,  39 ], //  37 - HOME
            [ 764,  32,  41,  39 ], //  38 - PGUP
            
            [ 827,  33,  41,  39 ], //  39 - CLEAR PAD
            [ 873,  33,  41,  39 ], //  40 - = PAD
            [ 918,  33,  41,  39 ], //  41 - / PAD
            [ 963,  33,  41,  39 ], //  42 - * PAD
            
            [   0,  77,  64,  39 ], //  43 - TAB
            [  66,  77,  41,  39 ], //  44 - Q
            [ 111,  77,  41,  39 ], //  45 - W
            [ 157,  77,  41,  39 ], //  46 - E
            [ 202,  77,  41,  39 ], //  47 - R
            [ 247,  77,  41,  39 ], //  48 - T
            [ 293,  77,  41,  39 ], //  49 - Y
            [ 338,  77,  41,  39 ], //  50 - U
            [ 383,  77,  41,  39 ], //  51 - I
            [ 429,  77,  41,  39 ], //  52 - O
            [ 474,  77,  41,  39 ], //  53 - P
            [ 520,  77,  41,  39 ], //  54 - [
            [ 565,  77,  41,  39 ], //  55 - ]
            [ 609,  77,  64,  39 ], //  56 - \
            
            [ 673,  77,  41,  39 ], //  57 - DEL
            [ 718,  77,  41,  39 ], //  58 - END
            [ 764,  77,  41,  39 ], //  59 - PGDN
            
            [ 827,  77,  41,  39 ], //  60 - 7 PAD
            [ 873,  77,  41,  39 ], //  61 - 8 PAD
            [ 918,  77,  41,  39 ], //  62 - 9 PAD
            [ 963,  77,  41,  39 ], //  63 - - PAD
            
            [   0, 121,  76,  39 ], //  64 - CAPS LOCK
            [  78, 121,  41,  39 ], //  65 - A
            [ 123, 121,  41,  39 ], //  66 - S
            [ 168, 121,  41,  39 ], //  67 - D
            [ 214, 121,  41,  39 ], //  68 - F
            [ 259, 121,  41,  39 ], //  69 - G
            [ 305, 121,  41,  39 ], //  70 - H
            [ 350, 121,  41,  39 ], //  71 - J
            [ 395, 121,  41,  39 ], //  72 - K
            [ 441, 121,  41,  39 ], //  73 - L
            [ 486, 121,  41,  39 ], //  74 - ;
            [ 531, 121,  41,  39 ], //  75 - '
            [ 575, 121,  76,  39 ], //  76 - RETURN
            
            [ 827, 121,  41,  39 ], //  77 - 4 PAD
            [ 873, 121,  41,  39 ], //  78 - 5 PAD
            [ 918, 121,  41,  39 ], //  79 - 6 PAD
            [ 963, 121,  41,  39 ], //  80 - + PAD
            
            [   0, 165,  97,  39 ], //  81 - SHIFT
            [  99, 165,  41,  39 ], //  82 - Z
            [ 144, 165,  41,  39 ], //  83 - X
            [ 189, 165,  41,  39 ], //  84 - C
            [ 234, 165,  41,  39 ], //  85 - V
            [ 280, 165,  41,  39 ], //  86 - B
            [ 326, 165,  41,  39 ], //  87 - N
            [ 371, 165,  41,  39 ], //  88 - M
            [ 416, 165,  41,  39 ], //  89 - ,
            [ 462, 165,  41,  39 ], //  90 - .
            [ 507, 165,  41,  39 ], //  91 - /
            [ 553, 165,  98,  39 ], //  92 - SHIFT
            
            [ 718, 173,  42,  38 ], //  93 - UP
            
            [ 827, 165,  41,  39 ], //  94 - 1 PAD
            [ 873, 165,  41,  39 ], //  95 - 2 PAD
            [ 918, 165,  41,  39 ], //  96 - 3 PAD
            [ 964, 165,  40,  91 ], //  97 - ENTER
            
            [   0, 209,  63,  46 ], //  98 - CONTROL
            [  66, 209,  54,  46 ], //  99 - OPTION
            [ 123, 209,  64,  46 ], // 100 - COMMAND
            [ 191, 209, 267,  46 ], // 101 - SPACE
            [ 462, 209,  63,  46 ], // 102 - COMMAND
            [ 529, 209,  53,  46 ], // 103 - OPTION
            [ 587, 209,  64,  46 ], // 104 - CONTROL
            
            [ 673, 217,  41,  39 ], // 105 - LEFT
            [ 718, 217,  41,  39 ], // 106 - DOWN
            [ 764, 217,  41,  39 ], // 107 - RIGHT
            
            [ 828, 209,  85,  46 ], // 108 - 0 PAD
            [ 919, 209,  40,  46 ], // 109 - . PAD
        ].enumerated().forEach { index, rect in
            keys.append(
                KeyboardKey(rect: CGRect(x: rect[0],
                                         y: rect[1],
                                         width: rect[2],
                                         height: rect[3]),
                            state: .up))
            
            for y in (rect[1]...rect[1]+rect[3]) {
                for x in (rect[0]...rect[0]+rect[2]) {
                    hitMatrix[y, x] = index
                }
            }
        }
    }

    func indexForTouch(_ touch: UITouch) -> Int? {
        for i in 0..<keyTouches.count {
            if touch == keyTouches[i].touch {
                return i
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var refresh = false
        
        touches.forEach { touch in
            let point = touch.location(in: self)
            
            if bounds.contains(point) {
                let keycode = hitMatrix[Int(point.y),
                                        Int(point.x)]
                
                if keycode > 0 {
                    keys[keycode].state = .down
                    
                    keyTouches.append(KeyboardTouch(touch: touch,
                                                    keycode: keycode))
                    
                    refresh = true
                }
            }
        }
        
        if refresh {
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var refresh = false
        
        touches.forEach { touch in
            if let index = indexForTouch(touch) {
                keys[keyTouches[index].keycode].state = .up
                keyTouches.remove(at: index)
                
                refresh = true
            }
        }
        
        if refresh {
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        var refresh = false
        
        touches.forEach { touch in
            if let index = indexForTouch(touch) {
                keys[keyTouches[index].keycode].state = .up
                keyTouches.remove(at: index)
                
                refresh = true
            }
        }
        
        if refresh {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        keyboardImage.draw(at: .zero)
        
        /*keyboardImage.draw(in: CGRect(x: 0,
                                      y: 0,
                                      width: 1004 / 2.87,
                                      height: 256 / 2.86))*/
        
        var keyRects = [CGRect]()
        
        keyTouches.forEach { keyTouch in
            keyRects.append(keys[keyTouch.keycode].rect)
        }
        
        if keyRects.count > 0,
            let context = UIGraphicsGetCurrentContext() {
            context.clip(to: keyRects)
            keyboardPressedImage.draw(at: CGPoint.zero)
        }
    }
    
}
