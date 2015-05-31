//
//  CollectionViewDetailViewController.swift
//  Reader
//
//  Created by Niket Shah on 30/05/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import WebKit

class CollectionViewDetailViewController: NSViewController {


	@IBOutlet weak var webView: WebView!
	
	
	var svg: String = "" {
		didSet {
			let svgWithDimensions = svg.stringByReplacingOccurrencesOfString("<svg", withString: "<svg width=\"800px\" height=\"800px\"", options: NSStringCompareOptions.allZeros, range: nil)

			webView.mainFrame.frameView.documentView.scaleUnitSquareToSize(NSMakeSize(1.6, 1.6))
			webView.mainFrame.loadHTMLString(svgWithDimensions, baseURL: ReaderConfig.pdfLibraryPath)

//			let source = SVGKSource(contentsOfString: svg)
//			let image = SVGKImage(source: source)
//			image.size = imageView.bounds.size
//			imageView.image = image
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
