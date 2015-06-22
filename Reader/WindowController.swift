//
//  WindowController.swift
//  Reader
//
//  Created by Niket Shah on 09/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
	
	//MARK: Properties
	@IBOutlet var titleLabelCell: NSTextFieldCell!
	
	var title: String = "Hello" {
		didSet {
			titleLabelCell.title = title
		}
	}
	
	
	
    // MARK: - Overrides
    
    override var document: AnyObject? {
        didSet {
            let contentViewController = window!.contentViewController as! ContentViewController
            
            contentViewController.document = document as? Document
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
