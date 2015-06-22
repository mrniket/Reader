//
//  FigureCollectionCell.swift
//  Reader
//
//  Created by Niket Shah on 30/05/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import JNWCollectionView

class FigureCollectionCell: JNWCollectionViewCell {

	@IBOutlet weak var headingLabel: NSTextField!
	
	var figure: Figure? {
		didSet {
			if let fig = figure {
				headingLabel.stringValue = fig.heading
			}
		}
	}
	
	override func awakeFromNib() {
		self.backgroundColor = NSColor(calibratedRed: 125, green: 170, blue: 208, alpha: 1)
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
