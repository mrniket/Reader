//
//  AuthenticatorProtocol.swift
//  Reader
//
//  Created by Niket Shah on 13/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

protocol AuthenticatorType: class {
	
	func isAuthenticated() -> Bool
	func getLoginWindowController() -> NSWindowController
	func clearAuthentication()
	
}
