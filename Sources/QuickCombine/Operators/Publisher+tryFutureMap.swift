//
//  tryFutureMap.swift
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
    ///   - transform: A closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, Failure>) -> Void) -> Void) -> Publishers.TryFutureMap<Self, T> {
        return Publishers.TryFutureMap(upstream: self, transform: transform)
    }
    
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure once. Any additional invocations of `promise` will be ignored.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) -> Void) -> Publishers.TryFutureMap<Publishers.MapError<Self, Error>, T> where U: Error {
        let typeErasedTransform = { (value: Output, promise: (Result<T, Error>) -> Void) -> Void in
            let typedPromise = { (result: Result<T, U>) -> Void in
                switch result {
                case let .success(output): promise(.success(output))
                case let .failure(error): promise(.failure(error as Error))
                }
            }
            transform(value, typedPromise)
        }
        return Publishers.TryFutureMap(upstream: self.mapError { $0 as Error }, transform: typeErasedTransform)
    }
    
    /// Transforms all elements from the upstream publisher asynchronously with a provided error-throwing closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure throw an error once. Any additional invocations of `promise` or errors thrown will be ignored.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) throws -> Void) -> Publishers.TryFutureMap<Publishers.MapError<Self, Error>, T> where U: Error {
        let typeErasedTransform = { (value: Output, promise: (Result<T, Error>) -> Void) -> Void in
            let typedPromise = { (result: Result<T, U>) -> Void in
                switch result {
                case let .success(output): promise(.success(output))
                case let .failure(error): promise(.failure(error as Error))
                }
            }
            do {
                try transform(value, typedPromise)
            } catch {
                promise(.failure(error))
            }
        }
        return Publishers.TryFutureMap(upstream: self.mapError { $0 as Error }, transform: typeErasedTransform)
    }
}

public extension Publisher where Failure == Error {
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure once. Any additional invocations of `promise` will be ignored.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) -> Void) -> Publishers.TryFutureMap<Self, T> where U: Error {
        let typeErasedTransform = { (value: Output, promise: (Result<T, Error>) -> Void) -> Void in
            let typedPromise = { (result: Result<T, U>) -> Void in
                switch result {
                case let .success(output): promise(.success(output))
                case let .failure(error): promise(.failure(error as Error))
                }
            }
            transform(value, typedPromise)
        }
        return Publishers.TryFutureMap(upstream: self, transform: typeErasedTransform)
    }
    
    /// Transforms all elements from the upstream publisher asynchronously with a provided error-throwing closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure throw an error once. Any additional invocations of `promise` or errors thrown will be ignored.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) throws -> Void) -> Publishers.TryFutureMap<Self, T> where U: Error {
        let typeErasedTransform = { (value: Output, promise: (Result<T, Error>) -> Void) -> Void in
            let typedPromise = { (result: Result<T, U>) -> Void in
                switch result {
                case let .success(output): promise(.success(output))
                case let .failure(error): promise(.failure(error as Error))
                }
            }
            do {
                try transform(value, typedPromise)
            } catch {
                promise(.failure(error))
            }
        }
        return Publishers.TryFutureMap(upstream: self, transform: typeErasedTransform)
    }
}

public extension Publisher where Failure == Never {
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Important: The provided `transform` closure may only invoke its `promise` closure once. Any additional invocations of `promise` will be ignored.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes an element and a promise as its parameters and, using the promise, asynchronously produces a new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses a promise in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryFutureMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) -> Void) -> Publishers.TryFutureMap<Publishers.SetFailureType<Self, U>, T> where U: Error {
        return Publishers.TryFutureMap(upstream: self.setFailureType(to: U.self), transform: transform)
    }
}

