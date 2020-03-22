//
//  Async.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

/// A publisher that asynchronously produces values.
public struct Async<Output>: Publisher {
    
    public typealias Failure = Never
    
    /// A type that represents a closure to invoke in the future when an element is available.
    ///
    /// The promise closure receives one paramater: a single element published by an `Async` publisher.
    public typealias Promise = (Output) -> Void
        
    private let task: (Promise) -> Void
    
    /// Creates a publisher that invokes a promise closure when the publisher emits an element.
    ///
    /// - Parameters:
    ///   - fulfill: An `Async.Promise` that the publisher invokes when the publisher emits elements.
    ///   - promise: A closure that is invoked in the future when an element is available. This closure may be invoked multiple times.
    public init(_ fulfill: @escaping (_ promise: Promise) -> Void) {
        self.task = fulfill
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscriptions.empty)
        let promise: Promise = { value in
            let _ = subscriber.receive(value)
        }
        task(promise)
    }
}
