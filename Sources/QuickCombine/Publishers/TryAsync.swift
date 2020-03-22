//
//  TryAsync.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

/// A publisher that asynchronously produces values or errors.
public struct TryAsync<Output, Failure>: Publisher where Failure: Error {
    
    /// A type that represents a closure to invoke in the future, when an element or error is available.
    ///
    /// The promise closure receives one parameter: a `Result` that contains either a single element published by a `TryAsync` publisher, or an error.
    public typealias Promise = (Result<Output, Failure>) -> Void
    
    private let task: (_ promise: Promise) -> Void
    
    /// Creates a publisher that invokes a promise closure when the publisher emits an element or an error.
    ///
    /// - Parameters:
    ///   - attemptToFulfill: A `TryAsync.Promise` that the publisher invokes when the publisher emits elements or errors.
    ///   - promise: A closure that is invoked in the future when an element or error is available. This closure may be invoked multiple times.
    public init(_ attemptToFulfill: @escaping (_ promise: Promise) -> Void) {
        self.task = attemptToFulfill
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscriptions.empty)
        let promise: Promise = { result in
            switch result {
            case let .failure(error):
                subscriber.receive(completion: .failure(error))
            case let .success(value):
                let _ = subscriber.receive(value)
            }
        }
        task(promise)
    }
}

extension TryAsync where Failure == Error {
    /// Creates a publisher that invokes a promise closure when the publisher emits an element or an error.
    ///
    /// - Parameters:
    ///   - attemptToFulfill: An error-throwing `TryAsync.Promise` that the publisher invokes when the publisher emits elements or errors.
    ///   - promise: A closure that is invoked in the future when an element or error is available. This closure may be invoked multiple times.
    public init(_ attemptToFulfill: @escaping (_ promise: Promise) throws -> Void) {
        self.task = { promise in
            do {
                try attemptToFulfill(promise)
            } catch {
                promise(.failure(error))
            }
        }
    }
}
