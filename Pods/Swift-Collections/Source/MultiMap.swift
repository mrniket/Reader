//
//  Multimap.swift
//  MoreCollections
//
//  Copyright (c) 2015 Swift-Collections project (https://github.com/jbulat/Swift-Collections)
//
import Foundation

// Implementation of Multimap that uses a Swift Array to store the values for a given key. A Swift Dictionary associates each key with an Array of values.
public struct Multimap<K:Hashable, V:Equatable> {
    typealias Values = [V]
    typealias Entry = (key:K, value:V)
    private var map: [K:Values] = [:]

    public init<S:SequenceType where S.Generator.Element == Entry>(_ sequence: S) {
        putAll(sequence)
    }

    public init() {
    }

    // Returns the number of key-value pairs in this Multimap.
    public var count: Int {
        var size = 0
        for key in map.keys {
            size += map[key]!.count
        }
        return size
    }

    // Returns a new array containing the key from each key-value pair in this Multimap
    public var keys: Set<K> {
        return Set(map.keys)
    }

    // Returns a new array containing the value from each key-value pair contained in this Multimap, without collapsing duplicates (so values.count == self.count).  Order is not deterministic
    public var values: [V] {
        var allValues = [V]()
        for (key, value) in self {
            allValues += [value]
        }
        return allValues
    }
    
    // Returns true if this Multimap contains no key-value pairs. Equivalent to count == 0 but more efficient when this Multimap is empty
    public var isEmpty: Bool {
        return map.count == 0 || self.count == 0;
    }

    // Returns true if this Multimap contains at least one key-value pair with the key key and the value value.
    public func containsEntry(key: K, value: V) -> Bool {
        return contains(get(key), value)
    }

    // Returns true if this Multimap contains at least one key-value pair with the key key.
    public func containsKey(key: K) -> Bool {
        return map[key] != nil;
    }

    //Returns true if this Multimap contains at least one key-value pair with the value value.
    public func containsValue(value: V) -> Bool {
        for key in map.keys {
            if (containsEntry(key, value: value)) {
                return true
            }
        }
        return false
    }

    // Returns a new array of the values associated with key in this Multimap, if any.
    public func get(key: K) -> [V] {
        if let values = map[key] {
            return values;
        }
        return []
    }

    // Stores a key-value pair in this Multimap.
    public mutating func put(key: K, value: V) {
        if (!containsKey(key)) {
            map[key] = []
        }
        map[key]!.append(value)
    }

    public mutating func putAll<S:SequenceType where S.Generator.Element == Entry>(sequence: S) {
        for entry in [Entry](sequence) {
            put(entry.key, value: entry.value)
        }
    }

    // Removes all key-value pairs with the key key and the value value from this Multimap, if such exists.
    public mutating func removeValueForKey(key: K, value: V) {
        map[key] = get(key).filter {
            $0 != value
        }
    }

    // Removes all values associated with the key key.
    public mutating func removeValuesForKey(key: K) {
        map.removeValueForKey(key)
    }

    // Removes all key-value pairs from the Multimap, leaving it empty.
    public mutating func removeAll() {
        map.removeAll()
    }

    public func filter(includeElement: (Entry) -> Bool) -> Multimap<K, V> {
        return Multimap(Swift.filter(self, includeElement))
    }

    public func map<OutKey:Hashable, OutValue:Equatable>(transform: (Entry) -> (OutKey, OutValue)) -> Multimap<OutKey, OutValue> {
        var result = Multimap<OutKey, OutValue>()
        result.putAll(Swift.map(self, transform))
        return result
    }

    public func reduce<U>(initial: U, combine: (U, Entry) -> U) -> U {
        return Swift.reduce(self, initial, combine)
    }
}

extension Multimap: SequenceType {
    public func generate() -> IndexingGenerator<[Entry]> {
        var allEntries = [Entry]()
        for (key, values) in map {
            for item in values {
                let entry = (key, item)
                allEntries += [(entry)]
            }
        }
        return IndexingGenerator(allEntries)
    }
    
    subscript (key: K) -> Values {
        return get(key)
    }
}

// Equality conformance

extension Multimap: Equatable {
    public func equals(other: Multimap<K, V>) -> Bool {
        if (self.keys != other.keys) {
            return false
        }
        for key in self.keys {
            if (self.get(key) != other.get(key)) {
                return false
            }
        }
        return true
    }
}

public func ==<K, V>(lhs: Multimap<K, V>, rhs: Multimap<K, V>) -> Bool {
    return lhs.equals(rhs)
}