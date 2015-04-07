//
//  PDFUAXMLParser.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Foundation
import Swift_Collections

class PDFUAXMLParser: NSObject, NSXMLParserDelegate {
    
    private var content: PDFUAContent
    private let parser: NSXMLParser
    private var currentElementName: String?
    private var previousSection: PDFUAContentNode?
    private var headerStack : Stack<PDFUAContentNode>
    private var currentSection: PDFUAContentNode?
    
    init(xmlData: NSData) {
        self.content = PDFUAContent()
        self.parser = NSXMLParser(data: xmlData)
        self.headerStack = Stack<PDFUAContentNode>()
        super.init()
        self.parser.delegate = self
    }
    
    func parse() -> PDFUAContent {
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
                if let currentSectionNode = currentSection {
                    headerStack.push(currentSectionNode)
                    currentSection = content.addSubSection(actualText, parentSection: currentSectionNode)
                } else {
                    currentSection = content.addSection(actualText)
                }
            }
        } else if isParagraph(elementName) {
            if let actualText: String = attributeDict["actualText"] as? String {
                content.addParagraph(paragraph: actualText, forSection: currentSection)
            }
        }

    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if isHeader(elementName) {
            currentSection = headerStack.pop()
        }
    }
    
    private func isHeader(elementName: String?) -> Bool {
        let elementNameUpperCased: String? = elementName?.uppercaseString
        return elementNameUpperCased == "H1" || elementNameUpperCased == "H2" || elementNameUpperCased == "H3" || elementNameUpperCased == "H4" || elementNameUpperCased == "H5" || elementNameUpperCased == "H6"
    }
    
    private func isParagraph(elementName: String?) -> Bool {
        let elementNameUpperCased: String? = elementName?.uppercaseString
        return elementNameUpperCased == "P"
    }
}