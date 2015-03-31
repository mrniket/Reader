//
//  PDFTagger.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Foundation


func tagPDF(#filePath: String) {
    let task = NSTask()
    task.launchPath = "/usr/bin/java"
    task.arguments = ["-jar", "/Users/Niket/projects/pdftagger/out/artifacts/pdftagger_jar2/pdftagger.jar", "-mode", "tag", "-s", filePath, "-o", ReaderConfig.pdfLibraryPath + filePath.lastPathComponent]
    task.launch()
    task.waitUntilExit()
}