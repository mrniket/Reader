//
//  DocumentProviderType.swift
//  Reader
//
//  Created by Niket Shah on 17/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

protocol DocumentProviderType: class {
	
	func listDocuments()
	func downloadDocument(#id: String, filename: String)
	
}

