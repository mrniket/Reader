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
    
    static let testPdfFilePath = "/Users/Niket/Desktop/pdfin/KLEE.pdf"
    
    override class func setUp() {
        super.setUp()
        ReaderConfig.pdfLibraryPath = "/Users/Niket/Desktop/ReaderFiles/TestFiles/TestLibrary/"
        if (NSFileManager.defaultManager().fileExistsAtPath("/Users/Niket/Desktop/ReaderFiles/TestFiles/TestLibrary/KLEE.pdf")) {
            NSFileManager.defaultManager().removeItemAtPath("/Users/Niket/Desktop/ReaderFiles/TestFiles/TestLibrary/KLEE.pdf", error: nil)
        }
        tagPDF(filePath: self.testPdfFilePath)
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: PDFTagger Tests
    
    func testPDFTaggedSucceeded() {
        expect(NSFileManager.defaultManager().fileExistsAtPath(ReaderConfig.pdfLibraryPath + PDFTests.testPdfFilePath.lastPathComponent)).to(beTrue())
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
        let contentInteractor = ContentInteractor(content: content)
        expect(contentInteractor.totalNumberOfHeadersAndParagraphs).to(equal(91))
    }
    
    func testTagCheckPDF() {
        expect(isTaggedPDF(filePath: PDFTests.testPdfFilePath)).to(beFalse())
        expect(isTaggedPDF(filePath: ReaderConfig.pdfLibraryPath + "KLEE.pdf")).to(beTrue())
    }
    
    
    // MARK: PDFUAContent Tests
    
    func testHeaderStructureParsedCorrectly() {
        let parsedData = parsePDF(filePath: ReaderConfig.pdfLibraryPath + "KLEE.pdf")
        let content = PDFUAXMLParser(xmlData: parsedData).parse()
        let contentInteractor = ContentInteractor(content: content)
        let tableOfContents = contentInteractor.tableOfContents
        expect(tableOfContents.count).to(equal(27))
        expect(tableOfContents.filter {$0.level == 0}.count).to(equal(8))
        expect(tableOfContents.filter {$0.level == 1}.count).to(equal(15))
        expect(tableOfContents.filter {$0.level == 2}.count).to(equal(4))
    }

}
