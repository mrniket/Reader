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
	
	var applicationSupportDirectory: NSURL {
		get {
			var appSupportDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
			let readerSupportDir = NSURL(fileURLWithPath: appSupportDir)!.URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
			if !(NSFileManager.defaultManager().fileExistsAtPath(readerSupportDir.absoluteString!)) {
				var error: NSError?
				NSFileManager.defaultManager().createDirectoryAtURL(readerSupportDir, withIntermediateDirectories: true, attributes: nil, error: &error)
				if error != nil {
					println(error?.localizedDescription)
				}
			}
			return readerSupportDir
		}
	}
	
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
			MendeleyKit.sharedInstance().fileWithFileID(id, saveToURL: applicationSupportDirectory.URLByAppendingPathComponent("KLEE.pdf"), progressBlock: { (number: NSNumber?) -> Void in
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
						self.delegate?.downloadedDocument(id)
					}
			})
		}
	}
	
}

protocol MendeleyDocumentProviderDelegate: class {
	
	func downloadedDocument(id: String)
	func fetchedFileList(files: [MendeleyFile])
	
}
