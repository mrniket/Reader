//
//  FigureWindowController.swift
//  Reader
//
//  Created by Niket Shah on 30/05/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class FigureWindowController: NSWindowController {
	
	override var document: AnyObject? {
		didSet {
			if let splitViewController = window!.contentViewController as? NSSplitViewController,
				splitItem = splitViewController.splitViewItems[0] as? NSSplitViewItem,
				figureCollectionViewController = splitItem.viewController as? CollectionViewController {
					println("got here!!!")
				figureCollectionViewController.document = document as? Document
			}
			
//			contentViewController.document = document as? Document
		}
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		
		// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	}
	
}
