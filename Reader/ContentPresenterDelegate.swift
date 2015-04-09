//
//  ContentPresenterDelegate.swift
//  Reader
//
//  Created by Niket Shah on 09/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

protocol ContentPresenterDelegate: class {
    
    func paragraphChanged(paragraphText: String)
    func sectionChanged(sectionText: String)
    
}
