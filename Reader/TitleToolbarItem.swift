//
//  TitleToolbarItem.swift
//  Reader
//
//  Created by Niket Shah on 17/06/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class TitleToolbarItem: NSToolbarItem {
	
	override var view: NSView? {
		get {
			var newView = super.view
			if var frame: CGRect = newView?.frame {
				frame.size.height = 45
				frame.origin.y = 5
				newView?.frame = frame
			}
			return newView
		}
		set {
			super.view = newValue
		}
	}

}
