//
//  Stack.swift
//  MoreCollections
//
//  Copyright (c) 2015 Swift-Collections project (https://github.com/jbulat/Swift-Collections)
//
import Foundation

public struct Stack<T:Equatable> {
    private var delegate: [T] = []
    
    public init<S:SequenceType where S.Generator.Element == T>(_ sequence: S) {
        pushAll(sequence)
    }
    
    public init() {
    }
    
    public var count: Int {
        return delegate.count
    }
    
    public var isEmpty: Bool {
        return delegate.isEmpty
    }
    
    public mutating func push(item:T){
        delegate.append(item)
    }
    
    public mutating func pushAll<S:SequenceType where S.Generator.Element == T>(sequence: S) {
        for item in [T](sequence) {
            push(item)
        }
    }
    
    public mutating func pop() -> T? {
        var last = delegate.last
        if last != nil {
            delegate.removeLast()
        }
        return last
    }
    
    public func peek() -> T?{
        return delegate.last
    }
    
    public mutating func removeAll() {
        delegate.removeAll()
    }
    
    public func filter(includeElement: (T) -> Bool) -> Stack<T> {
        return Stack<T>(delegate.filter(includeElement))
    }
    
    public func map<U>(transform: (T) -> U) -> Stack<U> {
        return Stack<U>(delegate.map(transform))
    }
    
    public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
        return Swift.reduce(delegate, initial, combine)
    }
}

extension Stack: SequenceType {
    public func generate() -> GeneratorOf<T> {
        return GeneratorOf(delegate.generate())
    }
}

extension Stack: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        pushAll(elements)
    }
}

extension Stack: Equatable {
    public func equals(other: Stack<T>) -> Bool {
        return self.delegate == other.delegate
    }
}

public func ==<T>(lhs: Stack<T>, rhs: Stack<T>) -> Bool {
    return lhs.equals(rhs)
}
