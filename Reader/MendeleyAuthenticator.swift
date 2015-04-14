//
//  MendeleyAuthenticator.swift
//  Reader
//
//  Created by Niket Shah on 13/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa
import MendeleyKit

class MendeleyAuthenticator: AuthenticatorType {
	
	init() {
		MendeleyKitConfiguration.sharedInstance().configureOAuthWithParameters(MendeleyConfig.asDictionary())
		let networkProviderParameters = [kMendeleyNetworkProviderKey: MendeleyNSURLConnectionProvider.className()]
		MendeleyKitConfiguration.sharedInstance().changeConfigurationWithParameters(networkProviderParameters)
	}
	
	func isAuthenticated() -> Bool {
		return MendeleyKit.sharedInstance().isAuthenticated
	}
	
	func getLoginWindowController() -> NSWindowController {
		var loginViewController: MendeleyLoginWindowController? = nil
		loginViewController =  MendeleyLoginWindowController(clientKey: MendeleyConfig.clientID, clientSecret: MendeleyConfig.secret, redirectURI: MendeleyConfig.redirectURL, completionBlock: { (sucess, error) -> Void in
			//                self.window?.endSheet(self.loginController!.window!)
			loginViewController!.window!.sheetParent?.endSheet(loginViewController!.window!)
//			NSApp.endSheet(loginViewController!.window!)
			println("authenticated via login")
			println(sucess)
			if error != nil {
				println(error)
			}
		})
		return loginViewController!
	}
	
	func clearAuthentication() {
		MendeleyKit.sharedInstance().clearAuthentication()
	}
	
}
