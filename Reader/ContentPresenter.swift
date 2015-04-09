//
//  ContentPresenter.swift
//  Reader
//
//  Created by Niket Shah on 09/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class ContentPresenter: ContentPresenterType {
    
    // MARK: - ContentPresenterType Properties
    
    weak var delegate: ContentPresenterDelegate?
    
    // MARK: - ContentPresenterType Methods
    
    func changeParagraph(#paragraph: PDFUAContentNode) {
        delegate?.paragraphChanged(paragraph.content)
    }
    
    func changeSection(#section: PDFUAContentNode) {
        delegate?.sectionChanged(section.content)
    }
    
}
