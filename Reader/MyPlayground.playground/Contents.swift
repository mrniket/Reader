//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import QuartzCore

var str = "Hello, playground"

class Progress {
	let wordCountArray: [Int]
	let total: Int
	
	init() {
		wordCountArray = []
		total = 0
	}
	
	init(paragraphList: [String]) {
		var count = 0
		wordCountArray = paragraphList.map { (paragraph: String) -> Int in
			count += paragraph.wordCount()
			return count
		}
		total = count
	}

}

protocol WordCountable {
	func wordCount() -> Int
}

extension String: WordCountable {
	
	func wordCount() -> Int {
		return self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).count
	}
	
}


