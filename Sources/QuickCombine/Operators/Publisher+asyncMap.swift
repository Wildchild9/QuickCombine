//
//  Publisher+asyncMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    /// Transforms all elements from the upstream publisher asyncronously with a provided closure.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes an element and a promise as its parameters and, using the promise, asyncronously produces new elements.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func asyncMap<T>(_ transform: @escaping (_ value: Output, _ promise: Publishers.AsyncMap<Self, T>.Promise) -> Void) -> Publishers.AsyncMap<Self, T> {
        return Publishers.AsyncMap(upstream: self, transform: transform)
    }
}
