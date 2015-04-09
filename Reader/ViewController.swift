//
//  ViewController.swift
//  Reader
//
//  Created by Niket Shah on 30/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, ContentPresenterDelegate {
    
    // MARK: Properties
    
    weak var document: Document? {
        didSet {
            if document == nil { return }
            
            let contentPresenter = ContentPresenter()
            contentPresenter.delegate = self
            
            document!.contentPresenter = contentPresenter
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

