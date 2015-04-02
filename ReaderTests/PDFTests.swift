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
        ReaderConfig.pdfLibraryPath = "/Users/Niket/Desktop/ReaderFiles/TestFiles/TestLibrary/"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPDFTaggedSucceeded() {
        if (NSFileManager.defaultManager().fileExistsAtPath("/Users/Niket/Desktop/ReaderFiles/TestFiles/TestLibrary/KLEE.pdf")) {
            NSFileManager.defaultManager().removeItemAtPath("/Users/Niket/Desktop/ReaderFiles/TestFiles/TestLibrary/KLEE.pdf", error: nil)
        }
        let testPdfFilePath = "/Users/Niket/Desktop/pdfin/KLEE.pdf"
        tagPDF(filePath: testPdfFilePath)
        expect(NSFileManager.defaultManager().fileExistsAtPath(ReaderConfig.pdfLibraryPath + testPdfFilePath.lastPathComponent)).to(beTrue())
    }
    
    func testParsePDF() {
        let parsedData = parsePDF(filePath: ReaderConfig.pdfLibraryPath + "KLEE.pdf")
        let expectedData = NSFileManager.defaultManager().contentsAtPath("/Users/Niket/Desktop/ReaderFiles/TestFiles/test.xml")
        let string = NSString(data: parsedData, encoding: 4)
        let anotherString = NSString(data: expectedData!, encoding: 4)
        expect(parsedData).to(equal(expectedData))
    }
    
    func testParseXML() {
        let parsedData = parsePDF(filePath: ReaderConfig.pdfLibraryPath + "KLEE.pdf")
        let content = PDFUAXMLParser(xmlData: parsedData).parse()
        expect(content.getTotalNumberOfHeadersAndParagraphs()).to(equal(91))
    }

}
