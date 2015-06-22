//
//  ViewController.swift
//  Reader
//
//  Created by Niket Shah on 30/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import JESCircularProgressView

class ContentViewController: NSViewController, ContentPresenterDelegate {
	
	// MARK: - IBOutlets
	@IBOutlet var paragraphView: ContentTextView!
	
	@IBOutlet var backgroundColorTextView: NSTextField!
	
	@IBOutlet var progessIndicator: JESCircularProgressView!
	// MARK: - Properties
	
	weak var document: Document? {
		didSet {
			if document == nil { return }
			
			let contentPresenter = ContentPresenter()
			contentPresenter.delegate = self
			
			document!.content?.presenter = contentPresenter
			
			if let paragraphList = document!.content?.paragraphList {
				self.progress = Progress(paragraphList: paragraphList)
			}
		}
	}
	
	var progress: Progress?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		let contentView = view as! ContentView
		contentView.delegate = self
		paragraphView.font = NSFont.systemFontOfSize(24);
		
		let myLayer = CALayer()
		myLayer.frame = self.view.bounds
		myLayer.backgroundColor = NSColor.redColor().CGColor
		self.view.layer = myLayer
		self.view.layer?.setNeedsDisplay()
		
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	// MARK: ContentPresenterDelegate
	
	func paragraphChanged(paragraphText: String) {
		paragraphView.string = paragraphText
	}
	
	func sectionChanged(sectionText: String) {
		if let windowController = self.view.window?.windowController() as? WindowController {
			windowController.title = sectionText
		}
	}
	
}

// MARK: - ContentViewDelegate

extension ContentViewController: ContentViewDelegate {
 
	func leftArrowKeyPressed() {
		document?.content?.moveToPreviousParagraph()
		if let p = progress {
			p.previous()
			progessIndicator.setProgress(CGFloat(p.percentage()), animated: true)
		}
		
	}
	
	func rightArrowKeyPressed() {
		document?.content?.moveToNextParagraph()
		if let p = progress {
			p.next()
			progessIndicator.setProgress(CGFloat(p.percentage()), animated: true)
		}
	}
	
}

// MARK: - Font and Color Changes

extension ContentViewController {
	
	override func changeFont(sender: AnyObject?) {
		if var fontManager = sender as? NSFontManager {
			var font = fontManager.convertFont(paragraphView.textStorage!.font!)
			paragraphView.textStorage!.font = font
		}
	}
	
	override func changeColor(sender: AnyObject?) {
		if var colorPanel = sender as? NSColorPanel {
			paragraphView.backgroundColor = colorPanel.color
			backgroundColorTextView.backgroundColor = colorPanel.color
		}
	}
	
}

