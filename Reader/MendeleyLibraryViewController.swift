//
//  MendeleyLibraryViewController.swift
//  Reader
//
//  Created by Niket Shah on 17/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import MendeleyKit

class MendeleyLibraryViewController: NSViewController, NSTableViewDataSource {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var tableView: NSTableView!
	
	// MARK: Properties
	
	var files: [MendeleyFile]?
	var dataProvider: MendeleyDocumentProvider?
	
	// MARK: Overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		dataProvider = MendeleyDocumentProvider(delegate: self)
		dataProvider?.listDocuments()
		tableView.setDataSource(self)
    }
    
}

extension MendeleyLibraryViewController {
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		if let mendeleyFiles = files {
			return mendeleyFiles.count
		}
		return 0
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
		if let mendeleyFiles = files {
			let file = mendeleyFiles[row]
			let columnIdentifier = tableColumn!.identifier
			switch (columnIdentifier) {
				case "filename":
					return file.file_name
				case "filesize":
					let size = file.size as Int
					return String(size / 1024)
				case "docid":
					return file.document_id
				case "id":
					return file.catalog_id
				default:
					return "What is this?"
			}
		}
		return "No File Found"
	}
	
}

extension MendeleyLibraryViewController: MendeleyDocumentProviderDelegate {
	
	func fetchedFileList(files: [MendeleyFile]) {
		println("got here")
		self.files = files
		tableView.reloadData()
	}
	
	func downloadedDocument(id: String) {
		
	}
	
}
