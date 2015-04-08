//
//  ContentInteractor.swift
//  Reader
//
//  Created by Niket Shah on 08/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

// MARK: - ContentInteractorInput Protocol -

protocol ContentInteractorInput {
    
    // MARK: Paragraphs
    
    func moveToNextParagraph()
    func moveToPreviousParagraph()
    
    // MARK: Sections
    
    func moveToNextSection()
    func moveToPreviousSection()
}

// MARK: - ContentInteractorOutput Protocol -

protocol ContentInteractorOutput {
    
}

class ContentInteractor: NSObject {
    
    // MARK: Public Properties
    
    var content: PDFUAContent
    
    var currentParagraph: String {
        get {
            return ""
        }
    }
    
    var currentSection: String {
        get {
            return ""
        }
    }
    
    var tableOfContents: [PDFUAContentNode] {
        get {
            return content.tree.traverse.breadthFirst.filter({
                (node: PDFUAContentNode) -> Bool in
                return node.type == PDFUAContentType.H
            })
        }
    }
    
    var percentageCompleted : Int = 0
    
    // MARK: Private Properties
    
    var totalNumberOfHeadersAndParagraphs: Int {
        get {
            return content.tree.nodes.count
        }
    }
    
    // MARK: -
    
    init(content: PDFUAContent) {
        self.content = content
        super.init()
    }
}

// MARK: - ContentInteractor - ContentInteractorInput -
// TODO: Fill in stubs

extension ContentInteractor: ContentInteractorInput {
    
    // MARK: Paragraphs
    
    func moveToNextParagraph() {
        
    }
    
    func moveToPreviousParagraph() {
        
    }
    
    // MARK: Sections
    
    func moveToNextSection() {
        
    }
    
    func moveToPreviousSection() {
        
    }
}
