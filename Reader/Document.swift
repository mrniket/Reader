//
//  Document.swift
//  Reader
//
//  Created by Niket Shah on 30/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    var content: PDFUAContent?

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

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

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return nil
    }
    
    override func readFromURL(url: NSURL, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
//        {
        if !isTaggedPDF(filePath: url.path!) {
            tagPDF(filePath: url.path!)
        }
//        } ~> {
            let data = parsePDF(filePath: ReaderConfig.pdfLibraryPath + url.lastPathComponent!)
            self.content = PDFUAXMLParser(xmlData: data).parse()
//        }
        return true
    }

}

