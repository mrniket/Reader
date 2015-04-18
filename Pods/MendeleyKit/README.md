# MendeleyKit the Mendeley SDK for Objective C #
Version: 1.0.4:
13 April 2015
- the method to check authorisation status now returns a cancellable MendeleyTask object and a minor bug fix

Version: 1.0.3
26 March 2015
- minor change to ensure that completion handlers are executed on the main thread

Version: 1.0.1
23 March 2015
- add a convenience method to check if authentication is still valid
- add methods for a new /recently_read API service

Version: 1.0.0
9 March 2015
- small fix to show proper login screen size after rotating device

Version: 0.9.20
6 March 2015
- added functionality to create and update profiles
- added functionality to retrieve Mendeley registered academic status and discipline types

Version: 0.9.19
16 Feb 2015
- added properties to the profiles model to be in line with the official /profiles API

Version: 0.9.18
12 Feb 2015
- MendeleyKitHelper:isSuccessForResponse will return false if network operation is cancelled

Version: 0.9.17
09 February 2015
- ensure that cancelling file downloads calls the completion handler

Version: 0.9.16 alpha
30 January 2015
- added icon/photo support for user profiles in MendeleyKit
- other improvements and bug fixes

Version: 0.9.9 alpha
5 December 2014
- added OSX support to MendeleyKit. MendeleyKit project now has 3 targets, MendeleyKit (iOS), MendeleyKitTests (unit tests) and MendeleyKitOSX.framework. The MendeleyKit.podspec has been updated so that users can now include MendeleyKitOSX into their MacOSX project
- MendeleyLoginController has been renamed to MendeleyLoginViewController for iOS. For Mac OSX, use the newly created MendeleyLoginWindowController
- MendeleyAnnotation and MendeleyURLBuilder have been updated to support Mac OSX specific classes (e.g. NSColor - instead of UIColor)
- MendeleyKit.h has a new create file method, where developers can specify filename and content type. The existing method can still be used - it will assume PDF as content type 

Version: 0.8.9 alpha
11 November 2014
- all API methods in MendeleyKit now return a MendeleyTask object to allow cancellation of network calls. The method signatures for network provider and API helper classes were changed accordingly.
- Notice: the SDK makes use of a 3rd party code provided by Apple to check on network reachability. The code is provided in accordance with Apple licence (see source code file Reachability.h/.m)


Released: October 2014

** Important notice: this is an early pre-release version and is subject to change **

## About MendeleyKit ##
MendeleyKit is a standalone Objective C library providing convenience methods
and classes for using the [Mendeley API](http://dev.mendeley.com) in Mac OSX or
iOS applications.

Note, this is an alpha version of the MendeleyKit.

## Minimum Requirements ##

XCode 5.1.1
iOS 7.x or higher

## Installation/Cocoapod ##
The easiest way to include MendeleyKit in your project is to use cocoapods.
The Podfile in your project should include the following line

```
pod 'MendeleyKit', :git => 'https://github.com/Mendeley/mendeleykit.git'
```

From command line, simply do 
```
pod install
```

For further information on Cocoapods see [Cocoapods](http://cocoapods.org/).

Alternatively, you may clone the public MendeleyKit from our github repository.

## Getting Started ##
MendeleyKit XCode workspace includes a MendeleyKitExample project. This demonstrates
basic functionality such as authenticating with the Mendeley server, 
obtaining a list of documents, files and groups.

It is recommended to consult with the classes contained in the MendeleyKitExample project.

In addition the github repository includes a MendeleyKitHelp.zip file. This contains
a complete reference set in HTML and Docset format.

When running the MendeleyKitExample app, please ensure you have
- client ID
- client secret key
- redirect URI 

They need to be entered in the ViewController.h file.
Note: code containing client IDs, client secrets, redirect URI will not be accepted in pull requests!

[Mendeley API](http://dev.mendeley.com) has links to create your app client id, key and redirect URIs.

## Registering a Client with the Mendeley Dev Portal ##
Every client communicating with the server needs to be registered with the Mendeley developer portal [Mendeley API](http://dev.mendeley.com).

Registration is quick, painless and free. It will give you the 3 essential ingredients you will need to supply when using the MendeleyKit in your app
- client ID
- client secret key
- redirect URI

These values need to match *exactly* the ones from the dev portal.
The redirect URI should be a fully formed URL, such as - e.g. http://localhost/myredirect (rather than just 'localhost/myredirect). This avoids any pitfalls or 'Frame load interrupted' messages in the UIWebView kit.


## How to submit code ##
This is an early-bird version of the MendeleyKit. We welcome your thoughts and suggestions. If you would like to make active contributions, e.g. code changes/additions,

- code submissions should only be made to Development branch via pull requests. 
- you may create your own subbranches from Development and submit to it at will. However, if you want to merge it into Development then you would need to create a pull request
- Note: code containing client IDs, client secrets, redirect URI will not be accepted in pull requests!


## Software Releases ##
All official releases of the MendeleyKit are tagged versions on master. Mendeley reserves the rights to merge changes made to Development into master.
Each release will contain a RELEASE text file outlining changes made.

## Reporting Issues ##
Please use the Issues feature on github to report any problems you encounter with the MendeleyKit. 
For feedback/suggestions please contact: api@mendeley.com


