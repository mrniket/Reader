//
//  ReaderWindowController.swift
//  Reader
//
//  Created by Niket Shah on 07/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class ReaderWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    // MARK: Overrides
    
    override var document: AnyObject? {
        didSet {
            let readerViewController = window!.contentViewController as! ContentViewController
            readerViewController.document = document as? PDFDocument
        }
    }

}
