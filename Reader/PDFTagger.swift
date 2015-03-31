//
//  PDFTagger.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//
// Respresents all the functions for handling PDF files

import Foundation

/**
Tags a PDF file and adds it to the library

:param: filePath The file path of the PDF to be tagged
*/
public func tagPDF(#filePath: String) {
    let task = NSTask()
    task.launchPath = "/usr/bin/java"
    task.arguments = ["-jar", "/Users/Niket/projects/pdftagger/out/artifacts/pdftagger_jar2/pdftagger.jar", "-mode", "tag", "-s", filePath, "-o", ReaderConfig.pdfLibraryPath + filePath.lastPathComponent]
    task.launch()
    task.waitUntilExit()
}

public func parsePDF(#filePath: String) {
    let task = NSTask()
    task.arguments = ["-jar", "/Users/Niket/projects/pdftagger/out/artifacts/pdftagger_jar2/pdftagger.jar", "-mode", "parse", "-s", filePath]
    task.launch()
    task.waitUntilExit()
}