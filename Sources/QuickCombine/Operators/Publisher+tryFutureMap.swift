//
//  tryFutureMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    /// Transforms all elements from the upstream publisher asyncronously with a provided closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure once. Any additional invocations of `promise` will be ignored.
    ///
    /// - Parameters:
    ///   - transform: Aclosure that takes an element and a promise as its parameters and, using the promise, asyncronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an elemen or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T>(transform: @escaping (_ value: Output, _ promise: Publishers.TryFutureMap<Self, T>.Promise) -> Void) -> Publishers.TryFutureMap<Self, T> {
        return Publishers.TryFutureMap(upstream: self, transform: transform)
    }
}

public extension Publisher where Failure == Error {
    /// Transforms all elements from the upstream publisher asyncronously with a provided error-throwing closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure once. Any additional invocations of `promise` will be ignored.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes an element and a promise as its parameters and, using the promise, asyncronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an elemen or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T>(transform: @escaping (_ value: Output, _ promise: Publishers.TryFutureMap<Self, T>.Promise) throws -> Void) -> Publishers.TryFutureMap<Self, T> {
        return Publishers.TryFutureMap(upstream: self, transform: transform)
    }
}
