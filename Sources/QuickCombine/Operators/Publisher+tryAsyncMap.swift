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
    func tryAsyncMap<T>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, Failure>) -> Void) -> Void) -> Publishers.TryAsyncMap<Self, T> {
        return Publishers.TryAsyncMap(upstream: self, transform: transform)
    }
    
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available. This closure receives one parameter: a `Result` that contains either a single element or an error.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) -> Void) -> Publishers.TryAsyncMap<Publishers.MapError<Self, Error>, T> where U: Error {
        let typeErasedTransform = { (value: Output, promise: (Result<T, Error>) -> Void) -> Void in
            let typedPromise = { (result: Result<T, U>) -> Void in
                switch result {
                case let .success(output): promise(.success(output))
                case let .failure(error): promise(.failure(error as Error))
                }
            }
            transform(value, typedPromise)
        }
        return Publishers.TryAsyncMap(upstream: self.mapError { $0 as Error }, transform: typeErasedTransform)
    }
    
    /// Transforms all elements from the upstream publisher asynchronously with a provided error-throwing closure.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) throws -> Void) -> Publishers.TryAsyncMap<Publishers.MapError<Self, Error>, T> where U: Error {
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
        return Publishers.TryAsyncMap(upstream: self.mapError { $0 as Error }, transform: typeErasedTransform)
    }
}

public extension Publisher where Failure == Error {
    /// Transforms all elements from the upstream publisher asynchronously with a provided closure.
    ///
    /// - Parameters:
    ///   - transform: A closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) -> Void) -> Publishers.TryAsyncMap<Self, T> where U: Error {
        let typeErasedTransform = { (value: Output, promise: (Result<T, Error>) -> Void) -> Void in
            let typedPromise = { (result: Result<T, U>) -> Void in
                switch result {
                case let .success(output): promise(.success(output))
                case let .failure(error): promise(.failure(error as Error))
                }
            }
            transform(value, typedPromise)
        }
        return Publishers.TryAsyncMap(upstream: self, transform: typeErasedTransform)
    }
    
    /// Transforms all elements from the upstream publisher asynchronously with a provided error-throwing closure.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping (Result<T, U>) -> Void) throws -> Void) -> Publishers.TryAsyncMap<Self, T> where U: Error {
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
        return Publishers.TryAsyncMap(upstream: self, transform: typeErasedTransform)
    }
}

public extension Publisher where Failure == Never {
    /// Transforms all elements from the upstream publisher asynchronously with a provided error-throwing closure.
    ///
    /// - Parameters:
    ///   - transform: An error-throwing closure that takes a element and a promise as its parameters and, using the promise, asynchronously produces new elements and/or errors.
    ///   - value: The upstream element.
    ///   - promise: The closure to invoke in the future, when an element or an error is available.
    /// - Returns: A publisher that uses promises in the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    func tryAsyncMap<T, U>(_ transform: @escaping (_ value: Output, _ promise: @escaping Publishers.TryAsyncMap<Publishers.SetFailureType<Self, U>, T>.Promise) -> Void) -> Publishers.TryAsyncMap<Publishers.SetFailureType<Self, U>, T> where U: Error {
        return Publishers.TryAsyncMap(upstream: self.setFailureType(to: U.self), transform: transform)
    }
}
    
