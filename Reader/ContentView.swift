//
//  ContentView.swift
//  Reader
//
//  Created by Niket Shah on 09/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import Foundation

protocol ContentViewDelegate: class {
    func leftArrowKeyPressed()
    func rightArrowKeyPressed()
}

class ContentView: NSView {
    
    // MARK: - Properties
    weak var delegate: ContentViewDelegate?
    
    // MARK: - Overrides
    
    override var acceptsFirstResponder: Bool { return true }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    
    // MARK: Handle Key Events
    
    override func keyDown(theEvent: NSEvent) {
        let arrow = theEvent.charactersIgnoringModifiers!.unicodeScalars
        let arrowKey = Int(arrow[arrow.startIndex].value)
        switch arrowKey {
        case NSLeftArrowFunctionKey:
            delegate?.leftArrowKeyPressed()
        case NSRightArrowFunctionKey:
            delegate?.rightArrowKeyPressed()
        default:
            break
        }
    }
    
}
