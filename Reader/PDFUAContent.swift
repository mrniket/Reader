//
//  Content.swift
//  Reader
//
//  Created by Niket Shah on 23/01/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//


import Swift_Collections

private enum PDFUAContentType {
    case H
    case P
    case Document
}

private struct PDFUAContentNode : Hashable {
    let type: PDFUAContentType
    let level: Int
    let content: String
    
    init(type: PDFUAContentType, level: Int, content: String) {
        self.type = type
        self.content = content
        self.level = level
    }
    
    //MARK - Hashable
    var hashValue : Int {
        get {
            return content.hashValue
        }
    }
}

// MARK - Equatable
private func ==(lhs: PDFUAContentNode, rhs: PDFUAContentNode) -> Bool {
    return (lhs.type == rhs.type) && (lhs.content == rhs.content)
}

/**
*  This class represents the contents of the TEI XML file created from the PDF file
*/
public class PDFUAContent {
    
    private let rootNode = PDFUAContentNode(type: PDFUAContentType.Document, level: 0, content: "")
    private var content: Tree<PDFUAContentNode>
    private var sectionList: [PDFUAContentNode]
    
    private lazy var currentSection: PDFUAContentNode = {
        [unowned self] in
        return self.content.getChildren(self.rootNode)[0]
        }()
    
    private lazy var currentParagraphs: [PDFUAContentNode] = {
        [unowned self] in
        self.content.traverse.breadthFirst
        }()
    
    private var paragraphIndex: Int = 0
    
    init() {
        self.content = Tree<PDFUAContentNode>()
        self.sectionList = []
    }
    
    private func findSection(sectionName: String) -> PDFUAContentNode? {
        for sectionNode in sectionList {
            if sectionNode.content == sectionName {
                return sectionNode
            }
        }
        return nil
    }
    
    public func addParagraph(#paragraph: String, forSection section: String?) {
        if let sect : String = section {
            if let sectionNode = findSection(sect) {
                let paragraph = PDFUAContentNode(type: PDFUAContentType.P, level: sectionNode.level, content: paragraph)
                content.addEdge(sectionNode, child: paragraph)
            }
        } else {
            let paragraph = PDFUAContentNode(type: PDFUAContentType.P, level: 0, content: paragraph)
            content.addEdge(rootNode, child: paragraph)
        }
        
    }
    
    public func addSection(section: String) {
        let sectionNode = PDFUAContentNode(type: PDFUAContentType.H, level: 0, content: section)
        content.addEdge(rootNode, child: sectionNode)
        sectionList.append(sectionNode)
    }
    
    public func addSubSection(section: String, parentSection: String) {
        if let parentNode = findSection(parentSection) {
            let sectionNode = PDFUAContentNode(type: PDFUAContentType.H, level: parentNode.level, content: section)
        }
    }
    
    public func getCurrentParagraph() -> String {
        return currentParagraphs[paragraphIndex].content
    }
    
    public func getCurrentSection() -> String {
        return currentSection.content
    }
    
    public func nextParagraph() {
        if paragraphIndex < self.currentParagraphs.count - 1 {
            paragraphIndex++
        }
    }
    
    public func previousParagraph() {
        if paragraphIndex > 0 {
            paragraphIndex--
        }
    }
    
    public func description() -> String {
        let children = self.content.getChildren(rootNode)
        var string: String = ""
        for child in children {
            string += child.content + "\n"
        }
        return string
    }
    
    func getTotalNumberOfHeadersAndParagraphs() -> Int {
        return self.content.nodes.count
    }
    
    
}

extension String
{
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}