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



	var webView: WKWebView?
	
	var svg: String = "" {
		didSet {
			let svgWithDimensions = svg.stringByReplacingOccurrencesOfString("<svg", withString: "<svg width=\"800px\" height=\"800px\"", options: NSStringCompareOptions.allZeros, range: nil)

			webView?.loadHTMLString(svgWithDimensions, baseURL: nil)
//			webView?.scaleUnitSquareToSize(NSMakeSize(1.6, 1.6))
//			webView?//.mainFrame.loadHTMLString(svgWithDimensions, baseURL: ReaderConfig.pdfLibraryPath)
//			webView?.mainFrame.frameView.documentView.scaleUnitSquareToSize(NSMakeSize(1.6, 1.6))

		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		let webViewConfiguration = WKWebViewConfiguration()
		webView = WKWebView(frame: self.view.bounds, configuration: webViewConfiguration)
		webView?.allowsMagnification = true
		webView?.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(webView!)
		view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: webView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
		
		
    }
    
}
