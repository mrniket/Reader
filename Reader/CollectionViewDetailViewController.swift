//
//  CollectionViewDetailViewController.swift
//  Reader
//
//  Created by Niket Shah on 30/05/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import SVGKit

class CollectionViewDetailViewController: NSViewController {


	
	@IBOutlet weak var imageView: SVGKLayeredImageView!
	
	var svg: String = "" {
		didSet {
			let source = SVGKSource(contentsOfString: svg)
			let image = SVGKImage(source: source)
			image.size = imageView.bounds.size
			imageView.image = image
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
