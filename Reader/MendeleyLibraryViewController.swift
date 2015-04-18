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
	@IBOutlet weak var openButton: NSButton!
	
	// MARK: Properties
	
	var files: [MendeleyFile]?
	var dataProvider: MendeleyDocumentProvider?
	
	// MARK: Overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		dataProvider = MendeleyDocumentProvider(delegate: self)
		tableView.setDataSource(self)
		tableView.setDelegate(self)
		dataProvider?.listDocuments()
		openButton.enabled = false
    }
	
	@IBAction func openButtonClicked(sender: NSButton) {
		if let mendeleyFiles = files {
			let index: Int = tableView.selectedRow
			if index > 0 {
				let file = mendeleyFiles[index]
				dataProvider?.downloadDocument(id: file.object_ID, filename: file.file_name)
			}
		}
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
					return file.object_ID
				default:
					return "What is this?"
			}
		}
		return "No File Found"
	}
	
}

extension MendeleyLibraryViewController: NSTableViewDelegate {
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		openButton.enabled = true
	}
	
}

extension MendeleyLibraryViewController: MendeleyDocumentProviderDelegate {
	
	func fetchedFileList(files: [MendeleyFile]) {
		self.files = files
		tableView.reloadData()
	}
	
	func downloadedDocument(location: NSURL) {
		let documentController: NSDocumentController = NSDocumentController.sharedDocumentController() as! NSDocumentController
		documentController.openDocumentWithContentsOfURL(location, display: true, completionHandler: { _ in })
	}
	
}
