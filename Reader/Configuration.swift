//
//  ReaderConfig.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import MendeleyKit


struct ReaderConfig {
	static var pdfLibraryFolder = "Reader Files/"
	
	static var pdfLibraryPath: NSURL {
		get {
			var appSupportDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
			let readerSupportDir = NSURL(fileURLWithPath: appSupportDir)!.URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!).URLByAppendingPathComponent(ReaderConfig.pdfLibraryFolder)
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
}

struct MendeleyConfig {
	static let secret = "6zlwhdUizdoENzK1"
	static let clientID = "1141"
	static let redirectURL = "http://reader://oauth"
	
	static func asDictionary() -> Dictionary<String, String> {
		return [kMendeleyOAuth2ClientIDKey: MendeleyConfig.clientID, kMendeleyOAuth2ClientSecretKey: MendeleyConfig.secret, kMendeleyOAuth2RedirectURLKey: MendeleyConfig.redirectURL]
	}
}
