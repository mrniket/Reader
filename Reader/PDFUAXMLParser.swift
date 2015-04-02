//
//  PDFUAXMLParser.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Foundation

class PDFUAXMLParser: NSObject, NSXMLParserDelegate {
    
    private var content: PDFUAContent
    private let parser: NSXMLParser
    private var currentElementName: String?
    private var currentSection: String?
    
    init(xmlData: NSData) {
        self.content = PDFUAContent()
        self.parser = NSXMLParser(data: xmlData)
        super.init()
    }
    
    func parse() -> PDFUAContent {
        self.parser.delegate = self
        self.parser.parse()
        return content
    }
    
    func parserDidStartDocument(parser: NSXMLParser) {
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        if isHeader(elementName) {
            if let actualText: String = attributeDict["actualText"] as? String {
                content.addSection(actualText)
            }
        } else if isParagraph(elementName) {
            if let actualText: String = attributeDict["actualText"] as? String {
                content.addParagraph(paragraph: actualText, forSection: currentSection)
            }
        }
    }
    
    private func isHeader(elementName: String?) -> Bool {
        let elementNameUpperCased: String? = elementName?.uppercaseString
        return elementNameUpperCased == "H1"
    }
    
    private func isParagraph(elementName: String?) -> Bool {
        let elementNameUpperCased: String? = elementName?.uppercaseString
        return elementNameUpperCased == "P"
    }
}