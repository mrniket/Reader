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
	
	var presenter: ContentPresenterType? {
		didSet {
			initParagraphAndSection()
			updateSection()
			updateParagraph()
		}
	}
	
	var tableOfContents : [PDFUAContentNode] {
		get {
			return content.traverse.breadthFirst.filter({
				(node: PDFUAContentNode) -> Bool in
				return node.type == PDFUAContentType.H
			})
		}
	}
	
	var paragraphList: [String] {
		get {
			return content.traverse.breadthFirst.filter({ $0.type == PDFUAContentType.P }).map { $0.content }
		}
	}
	
	var currentParagraph : PDFUAContentNode?
	
	var currentSection : PDFUAContentNode?
	
	var totalNumberOfHeadersAndParagraphs: Int {
		get {
			return content.nodes.count
		}
	}
	
	var figures : [Figure] = []
	
	// MARK: -
	
	private let rootNode = PDFUAContentNode(type: PDFUAContentType.Document, level: 0, content: "")
	private var content: Tree<PDFUAContentNode>
	private var sectionList: [PDFUAContentNode]
	private var contentList: [PDFUAContentNode] {
		get {
			return content.traverse.breadthFirst
		}
	}
	
	private var contentListIndex: Int
	
	
	private var paragraphIndex: Int = 0
	
	init() {
		self.content = Tree<PDFUAContentNode>()
		self.sectionList = []
		self.contentListIndex = 0
	}
	
	private func findSection(sectionName: String) -> PDFUAContentNode? {
		for sectionNode in sectionList {
			if sectionNode.content == sectionName {
				return sectionNode
			}
		}
		return nil
	}
	
	private func initParagraphAndSection() {
		currentParagraph = nil
		currentSection = nil
		contentListIndex = -1
		moveToNextParagraph()
	}
	
	private func findFirstSection() -> PDFUAContentNode? {
		for node in contentList {
			if node.type == PDFUAContentType.H {
				return node
			}
		}
		return nil
	}
	
	func addParagraph(#paragraph: String, forSection section: PDFUAContentNode?) -> PDFUAContentNode {
		let paragraphNode: PDFUAContentNode
		if let sectionNode = section {
			paragraphNode = PDFUAContentNode(type: PDFUAContentType.P, level: sectionNode.level, content: paragraph)
			content.addEdge(sectionNode, child: paragraphNode)
		} else {
			paragraphNode = PDFUAContentNode(type: PDFUAContentType.P, level: 0, content: paragraph)
			content.addEdge(rootNode, child: paragraphNode)
		}
		if currentParagraph == nil {
			initParagraphAndSection()
		}
		return paragraphNode
	}
	
	/**
	Adds the given section name to the top level sections
	
	:param: section The name of the section to add
	*/
	func addSection(section: String) -> PDFUAContentNode {
		let sectionNode = PDFUAContentNode(type: PDFUAContentType.H, level: 0, content: section)
		content.addEdge(rootNode, child: sectionNode)
		sectionList.append(sectionNode)
		return sectionNode
	}
	
	func addSubSection(section: String, parentSection: PDFUAContentNode?) -> PDFUAContentNode? {
		if let parentNode = parentSection {
			let sectionNode = PDFUAContentNode(type: PDFUAContentType.H, level: parentNode.level + 1, content: section)
			content.addEdge(parentNode, child: sectionNode)
			return sectionNode
		}
		return nil
	}
	
	func moveToNextParagraph() {
		// TODO: move to next paragraph
		if contentListIndex < contentList.count - 1 {
			contentListIndex++
			let nextNode = contentList[contentListIndex]
			if nextNode.type != PDFUAContentType.P {
				moveToNextParagraph()
			} else {
				currentParagraph = nextNode
			}
		}
		updateParagraph()
	}
	
	func moveToPreviousParagraph() {
		// TODO: move to previous paragraph
		if contentListIndex > 0 {
			contentListIndex--
			let nextNode = contentList[contentListIndex]
			if nextNode.type != PDFUAContentType.P {
				moveToPreviousParagraph()
			} else {
				currentParagraph = nextNode
			}
		}
		updateParagraph()
	}
	
	func description() -> String {
		let children = content.getChildren(rootNode)
		var string: String = ""
		for child in children {
			string += child.content + "\n"
		}
		return string
	}
	
	// MARK: - Helper Methods
	
	func updateParagraph() {
		updateSection()
		if let currentParagraphNode = currentParagraph {
			presenter?.changeParagraph(paragraph: currentParagraphNode)
		}
	}
	
	func updateSection() {
		if let currentParagraphNode = currentParagraph {
			if currentSection != content.getParent(currentParagraphNode) {
				currentSection = content.getParent(currentParagraphNode)
				if let currentSectionNode = currentSection {
					presenter?.changeSection(section: currentSectionNode)
				}
			}
		}
	}
}

extension String {
	func replace(target: String, withString: String) -> String {
		return stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
	}
}