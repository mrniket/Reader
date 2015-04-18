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
	
	func downloadDocument(#id: String, filename: String) {
		if MendeleyKit.sharedInstance().isAuthenticated {
			let fileURL = ReaderConfig.pdfLibraryPath.URLByAppendingPathComponent(filename)
			MendeleyKit.sharedInstance().fileWithFileID(id, saveToURL: fileURL, progressBlock: { (number: NSNumber?) -> Void in
				if let float = number as? Float {
					let percentage = float * 100
					println("downloading file: \(percentage)% complete")
				}
				}, completionBlock: { (success: Bool, error: NSError?) -> Void in
					if error != nil {
						println("it is \(success) that we have successfully downloaded a file!")
						println("and this is why \(error)")
					}
					if success {
						self.delegate?.downloadedDocument(fileURL)
					}
			})
		}
	}
	
}

protocol MendeleyDocumentProviderDelegate: class {
	
	func downloadedDocument(location: NSURL)
	func fetchedFileList(files: [MendeleyFile])
	
}
