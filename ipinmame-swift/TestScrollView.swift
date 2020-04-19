//
//  TestScrollView.swift
//  ipinmame-swift
//
//  Created by Jason Millard on 3/10/20.
//  Copyright © 2020 Jason Millard. All rights reserved.
//

import UIKit

class TestScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        subviews.first?.subviews.first?.touchesBegan(touches, with: event)

        //next?.next?.touchesBegan(touches, with: event)
        /*if !isDragging {
            print("!is dragging \(next)")
                
            subviews.first?.subviews.first?.touchesBegan(touches, with: event)
        }
        else {
            print("is dragging")
            
            super.touchesBegan(touches, with: event)
        }*/

    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        subviews.first?.subviews.first?.touchesEnded(touches, with: event)

        
        /*if !isDragging {
            print("!is dragging \(next)")
               
            subviews.first?.subviews.first?.touchesEnded(touches, with: event)

        }
        else {
            print("is dragging")
            
            super.touchesEnded(touches, with: event)
        }*/

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        subviews.first?.subviews.first?.touchesCancelled(touches, with: event)
           
        /*if !isDragging {
            print("!is dragging \(next)")
                
            subviews.first?.subviews.first?.touchesCancelled(touches, with: event)
        }
        else {
            print("is dragging")
            
            super.touchesCancelled(touches, with: event)
        }*/

    }

}
