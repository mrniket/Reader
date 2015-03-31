//
//  CustomOperators.swift
//  Reader
//
//  Created by Niket Shah on 31/03/2015.
//  Copyright (c) 2015 Niket Shah. All rights reserved.
//

import Foundation

infix operator ~> {}

/**
*  Serial dispatch queue used by the ~> operator
*/
private let queue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
*/
func ~> (
    backgroundClosure: () -> (),
    mainClosure:       () -> ())
{
    dispatch_async(queue) {
        backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), mainClosure)
    }
}

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
Passes the background closure's output to the main closure.

:param: backgroundClosure the lefthand closure
:param: mainClosure righthand closure
*/
func ~> <R> (backgroundClosure: () -> R, mainClosure: (result: R) -> ()) {
        dispatch_async(queue) {
            let result = backgroundClosure()
            dispatch_async(dispatch_get_main_queue(), {
                mainClosure(result: result)
            })
        }
}
