//
//  PDFTagger.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//
// Respresents all the functions for handling PDF files

import Foundation


let pdftaggerPath: String = NSBundle.mainBundle().pathForResource("pdftagger", ofType: "jar", inDirectory: "Java")!

/**
Tags a PDF file and adds it to the library

:param: filePath The file path of the PDF to be tagged
*/
public func tagPDF(#filePath: String) {
    let task = NSTask()
    task.launchPath = "/usr/bin/java"
    task.arguments = ["-jar", pdftaggerPath, "-mode", "tag", "-s", filePath, "-o", ReaderConfig.pdfLibraryPath.path! + "/" + filePath.lastPathComponent]
    task.launch()
    task.waitUntilExit()
}

/**
Parses an already tagged PDF and converts it into an XML representation

:param: filePath The file path of the PDF

:returns: An XML representation of the PDF file
*/
public func parsePDF(#filePath: String) -> NSData {
    let task = NSTask()
    let pipe = NSPipe()
    task.launchPath = "/usr/bin/java"
    task.arguments = ["-jar", pdftaggerPath, "-mode", "parse", "-s", filePath]
    task.standardOutput = pipe
    task.launch()
    return pipe.fileHandleForReading.readDataToEndOfFile()
}

/**
Copies the file given to the library if a file with teh same name does not already exist

:param: filePath The URL of the path to copy
*/
public func copyFileToLibrary(#filePath: NSURL) {
	var error: NSError?
	NSFileManager.defaultManager().copyItemAtURL(filePath, toURL: ReaderConfig.pdfLibraryPath.URLByAppendingPathComponent(filePath.lastPathComponent!), error: &error)
	if error != nil {
		println(error?.description)
	}
}

/**
Checks if the PDF file at the path given is a tagged PDF

:param: filePath The file path of the PDF

:returns: true if PDF is a tagged pdf, false otherwise
*/
public func isTaggedPDF(#filePath: String) -> Bool {
    let task = NSTask()
    let pipe = NSPipe()
    task.launchPath = "/usr/bin/java"
    task.arguments = ["-jar", pdftaggerPath, "-mode", "check", "-s", filePath]
    task.standardOutput = pipe
    task.launch()
    if let result = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding:NSUTF8StringEncoding) {
        return result.boolValue
    } else {
        return false
    }
}