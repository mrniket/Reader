//
//  Set.swift
//  MoreCollections
//
//  Copyright (c) 2015 Swift-Collections project (https://github.com/jbulat/Swift-Collections)
//
import Foundation

// A collection that contains no duplicate elements.  More formally, sets contain no pair of elements e1 and e2 such that e1 == e2

public struct Set<T:Hashable> {
    typealias IGNORED = Int
    private var delegate: [T:IGNORED] = [:]

    public init<S:SequenceType where S.Generator.Element == T>(_ sequence: S) {
        addAll(sequence)
    }

    public init() {
    }

    public var count: Int {
        return delegate.count
    }
    
    public var isEmpty : Bool {
        return delegate.isEmpty
    }

    public mutating func add(item: T) -> Bool {
        let isNew = !contains(item)
        delegate[item] = 0
        return isNew
    }

    public mutating func addAll<S:SequenceType where S.Generator.Element == T>(sequence: S) {
        for item in [T](sequence) {
            add(item)
        }
    }

    public mutating func remove(item: T) -> Bool {
        let exists = contains(item)
        delegate[item] = nil
        return exists
    }

    public mutating func removeAll<S:SequenceType where S.Generator.Element == T>(sequence: S) {
        for item in [T](sequence) {
            remove(item)
        }
    }

    public mutating func removeAll() {
        delegate.removeAll()
    }
    
    // Returns true if this set contains parameter item.  Alg complexity is is O(1), Swift.contains() is is O(n)
    public func contains(item : T) -> Bool {
        return delegate[item] != nil
    }

    public func containsAll<S:SequenceType where S.Generator.Element == T>(sequence: S) -> Bool {
        for item in [T](sequence) {
            if (!contains(item)) {
                return false
            }
        }
        return true
    }
    
    public func intersect(other: Set<T>) -> Set<T> {
        var intersection = Set<T>()
        intersection.addAll(self)
        intersection.addAll(other)
        return intersection
    }
    
    public func union(other: Set<T>) -> Set<T> {
        var union = Set<T>()
        for item in other {
            if self.contains(item){
                union.add(item)
            }
        }
        return union
    }

    public func filter(includeElement: (T) -> Bool) -> Set<T> {
        return Set<T>(delegate.keys.filter(includeElement))
    }

    public func map<U>(transform: (T) -> U) -> Set<U> {
        return Set<U>(delegate.keys.map(transform))
    }

    public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
        return Swift.reduce(delegate.keys, initial, combine)
    }
}

extension Set: SequenceType {
    public func generate() -> GeneratorOf<T> {
        return GeneratorOf(delegate.keys.generate())
    }
}

extension Set: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        addAll(elements)
    }
}

// Equality conformance

extension Set: Equatable {
    public func equals(other: Set<T>) -> Bool {
        return self.count == other.count && self.containsAll(other)
    }
}

public func ==<T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return lhs.equals(rhs)
}