//
//  Publisher+futureMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure once. Any additional invocations of `promise` will be ignored.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new element.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func futureMap<T>(transform: @escaping (_ value: Output, _ promise: Publishers.FutureMap<Self, T>.Promise) -> Void) -> Publishers.FutureMap<Self, T> {
        return Publishers.FutureMap(upstream: self, transform: transform)
    }
}
