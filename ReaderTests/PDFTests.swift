//
//  PDFTests.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import XCTest
import Nimble
import Reader

class PDFTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPDFTaggedSucceeded() {
        if (NSFileManager.defaultManager().fileExistsAtPath("Users/Niket/Desktop/ReaderFiles")) {
            NSFileManager.defaultManager().removeItemAtPath("Users/Niket/Desktop/ReaderFiles", error: nil)
        }
        let testPdfFilePath = "/Users/Niket/Desktop/pdfin/KLEE.pdf"
        tagPDF(filePath: testPdfFilePath)
        expect(NSFileManager.defaultManager().fileExistsAtPath(ReaderConfig.pdfLibraryPath + testPdfFilePath.lastPathComponent)).to(beTrue())
    }
    
    func testParsePDF() {
        
    }

}
