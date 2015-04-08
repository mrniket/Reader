//
//  Content.swift
//  Reader
//
//  Created by Niket Shah on 23/01/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//


import Swift_Collections

enum PDFUAContentType {
    case H
    case P
    case Document
}

struct PDFUAContentNode : Hashable {
    let type: PDFUAContentType
    let level: Int
    let content: String
    
    init(type: PDFUAContentType, level: Int, content: String) {
        self.type = type
        self.content = content
        self.level = level
    }
    
    //MARK: Hashable
    var hashValue : Int {
        get {
            return content.hashValue
        }
    }
}

// MARK: - Equatable
func ==(lhs: PDFUAContentNode, rhs: PDFUAContentNode) -> Bool {
    return (lhs.type == rhs.type) && (lhs.content == rhs.content)
}

/**
*  This class represents the contents of the TEI XML file created from the PDF file
*/
public class PDFUAContent {
    
    // MARK: Public properties
    
    var tree: Tree<PDFUAContentNode>
    
    // MARK: -
    
    private let rootNode = PDFUAContentNode(type: PDFUAContentType.Document, level: 0, content: "")
    private var sectionList: [PDFUAContentNode]
    
    
    private var currentParagraphs: [PDFUAContentNode] {
        get {
            return tree.traverse.breadthFirst
        }
    }
    
    private var paragraphIndex: Int = 0
    
    init() {
        self.tree = Tree<PDFUAContentNode>()
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
    
    /**
    Adds a paragraph to the the given section
    
    :param: paragraph The paragraph to add
    :param: section   The section to add the paragraph too
    
    :returns: The new paragraph node created
    */
    func addParagraph(#paragraph: String, forSection section: PDFUAContentNode?) -> PDFUAContentNode {
        let paragraphNode: PDFUAContentNode
        if let sectionNode = section {
            paragraphNode = PDFUAContentNode(type: PDFUAContentType.P, level: sectionNode.level, content: paragraph)
            tree.addEdge(sectionNode, child: paragraphNode)
        } else {
            paragraphNode = PDFUAContentNode(type: PDFUAContentType.P, level: 0, content: paragraph)
            tree.addEdge(rootNode, child: paragraphNode)
        }
        return paragraphNode
    }
    
    /**
    Adds the given section name to the top level sections
    
    :param: section The name of the section to add
    */
    func addSection(section: String) -> PDFUAContentNode {
        let sectionNode = PDFUAContentNode(type: PDFUAContentType.H, level: 0, content: section)
        tree.addEdge(rootNode, child: sectionNode)
        sectionList.append(sectionNode)
        return sectionNode
    }
    
    func addSubSection(section: String, parentSection: PDFUAContentNode?) -> PDFUAContentNode? {
        if let parentNode = parentSection {
            let sectionNode = PDFUAContentNode(type: PDFUAContentType.H, level: parentNode.level + 1, content: section)
            tree.addEdge(parentNode, child: sectionNode)
            return sectionNode
        }
        return nil
    }
    
    func moveToNextParagraph() {
        if paragraphIndex < currentParagraphs.count - 1 {
            paragraphIndex++
        }
    }
    
    func moveToPreviousParagraph() {
        if paragraphIndex > 0 {
            paragraphIndex--
        }
    }
    
    func description() -> String {
        let children = tree.getChildren(rootNode)
        var string: String = ""
        for child in children {
            string += child.content + "\n"
        }
        return string
    }
    
    
}

extension String {
    func replace(target: String, withString: String) -> String {
        return stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}