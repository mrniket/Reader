//
//  Progress.swift
//  Reader
//
//  Created by Niket Shah on 19/06/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Foundation

class Progress {
	let wordCountArray: [Int]
	let total: Int
	var index = 0
	
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
	
	func next() -> Double {
		if index < wordCountArray.count - 1 {
			index++
		}
		return percentage()
	}
	
	func previous() -> Double {
		if index > 0 {
			index--
		}
		return percentage()
	}
	
	func percentage() -> Double {
		return Double(wordCountArray[index])/Double(total)
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
