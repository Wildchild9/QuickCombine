//
//  tryAsyncMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T>(_ transform: @escaping (_ value: Output, _ promise: Publishers.TryAsyncMap<Self, T>.Promise) -> Void) -> Publishers.TryAsyncMap<Self, T> {
        return Publishers.TryAsyncMap(upstream: self, transform: transform)
    }
}

public extension Publisher where Failure == Error {
    /// Transforms all elements from the upstream publisher asynchronously with a provided error-throwing closure.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T>(_ transform: @escaping (_ value: Output, _ promise: Publishers.TryAsyncMap<Self, T>.Promise) throws -> Void) -> Publishers.TryAsyncMap<Self, T> {
        return Publishers.TryAsyncMap(upstream: self, transform: transform)
    }
}

