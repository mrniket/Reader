//
//  ContentPresenterType.swift
//  Reader
//
//  Created by Niket Shah on 09/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

protocol ContentPresenterType: class {
    
    // MARK: Properties
    
    weak var delegate: ContentPresenterDelegate? { get set }
    
    // MARK: Methods
    
    func changeParagraph(#paragraph: PDFUAContentNode)
    func changeSection(#section: PDFUAContentNode)
    
}
