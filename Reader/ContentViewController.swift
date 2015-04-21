//
//  ViewController.swift
//  Reader
//
//  Created by Niket Shah on 30/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController, ContentPresenterDelegate {
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var sectionField: NSTextField!
	@IBOutlet var paragraphView: ContentTextView!
	
	
	// MARK: - Properties
	
	weak var document: Document? {
		didSet {
			if document == nil { return }
			
			let contentPresenter = ContentPresenter()
			contentPresenter.delegate = self
			
			document!.content?.presenter = contentPresenter
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		let contentView = view as! ContentView
		contentView.delegate = self
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
		sectionField.stringValue = sectionText
	}
	
}

// MARK: - ContentViewDelegate

extension ContentViewController: ContentViewDelegate {
 
	func leftArrowKeyPressed() {
		document?.content?.moveToPreviousParagraph()
	}
	
	func rightArrowKeyPressed() {
		document?.content?.moveToNextParagraph()
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
		}
	}
	
}

