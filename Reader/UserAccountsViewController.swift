//
//  UserAccountsViewController.swift
//  Reader
//
//  Created by Niket Shah on 14/04/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Cocoa

class UserAccountsViewController: NSViewController {
	
	// MARK: Properties
	
	let authenticator: AuthenticatorType = MendeleyAuthenticator()
	
	// MARK: IBOutlets
	
	@IBOutlet weak var signInButton: NSButton!
	
	// MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		setSignInButtonText()
    }
	
	// MARK: Actions
	
	@IBAction func buttonClicked(sender: NSButton) {
		if authenticator.isAuthenticated() {
			authenticator.clearAuthentication()
		} else {
			let loginViewController = authenticator.getLoginWindowController()
			self.view.window!.beginSheet(loginViewController.window!, completionHandler: { (response: NSModalResponse) -> Void in
				println("ended")
			})
		}
	}
	
	// MARK: -
	
	func setSignInButtonText() {
		if authenticator.isAuthenticated() {
			signInButton.title = "Sign Out"
		} else {
			signInButton.title = "Sign In to Mendeley"
		}
	}
    
}
