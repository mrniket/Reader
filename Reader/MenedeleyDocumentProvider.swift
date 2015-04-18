//
//  MenedeleyDocumentProvider.swift
//  Reader
//
//  Created by Niket Shah on 17/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import MendeleyKit

class MendeleyDocumentProvider: DocumentProviderType {
	
	// MARK: Properties
	
	var delegate: MendeleyDocumentProviderDelegate?
	
	init(delegate: MendeleyDocumentProviderDelegate) {
		self.delegate = delegate
	}
	
	// MARK: DocumentProviderType Methods
	
	func listDocuments() {
		if MendeleyKit.sharedInstance().isAuthenticated {
			MendeleyKit.sharedInstance().fileListWithQueryParameters(MendeleyFileParameters(), completionBlock: { (files:[AnyObject]!, syncInfo: MendeleySyncInfo!, error: NSError?) -> Void in
				if let mendeleyFiles = files as? [MendeleyFile] {
					self.delegate?.fetchedFileList(mendeleyFiles)
				}
			})
		}
	}
	
	func downloadDocument(id: String) {
		if MendeleyKit.sharedInstance().isAuthenticated {
			MendeleyKit.sharedInstance().fileWithFileID(id, saveToURL: NSBundle.mainBundle().bundleURL, progressBlock: { (number: NSNumber?) -> Void in
				
				}, completionBlock: { (success: Bool, error: NSError?) -> Void in
					println("it is \(success) that we have successfully downloaded a file!")
					println("and this is why \(error)")
			})
		}
	}
	
}

protocol MendeleyDocumentProviderDelegate: class {
	
	func downloadedDocument(id: String)
	func fetchedFileList(files: [MendeleyFile])
	
}
