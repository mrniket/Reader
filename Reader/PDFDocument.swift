//
//  Document.swift
//  Reader
//
//  Created by Niket Shah on 30/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class PDFDocument: NSDocument {
    
    // MARK: Properties
    
    var content : PDFUAContent = PDFUAContent()
    
    // MARK: -
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }
    
    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }
    
    override func readFromURL(url: NSURL, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        {
            tagPDF(filePath: url.path!)
        } ~> {
            let data = parsePDF(filePath: ReaderConfig.pdfLibraryPath + url.path!.lastPathComponent)
            self.content = PDFUAXMLParser(xmlData: data).parse()
        };
        return true
    }
    
    
}

