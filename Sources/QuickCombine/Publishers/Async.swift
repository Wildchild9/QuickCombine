//
//  Async.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

/// A publisher that asyncronously produces values.
public final class Async<Output>: Publisher {
    
    public typealias Failure = Never
    
    /// A type that represents a closure to invoke in the future when an element is available.
    ///
    /// - Parameters:
    ///    - result: An element published by an `Async` publisher.
    ///    - completionState: The completion state of the asyncronous task. If `.finished`, then all subsequent promises are ignored and a finished completion state is passed along.
    public typealias Promise = (_ result: Output, _ completionState: CompletionState) -> Void
        
    private var task: (Promise) -> Void
    private var isFinished = false
    
    /// Creates a publisher that invokes a promise closure when the publisher emits an element.
    ///
    /// - Parameters:
    ///   - fulfill: An `Async.Promise` that the publisher invokes when the publisher emits elements.
    ///   - promise: A closure that consistes of two parameters, an element and a completion state, that is invoked in the future. Invoking this closure multiple times will subsequently output multiple downstream values. Passing `.finished` will cause the publisher to cease sending values downstream.
    public init(_ fulfill: @escaping (_ promise: Promise) -> Void) {
        self.task = fulfill
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscriptions.empty)
        let promise: Promise = { value, completionState in
            if !self.isFinished {
                let _ = subscriber.receive(value)
                if completionState == .finished {
                    subscriber.receive(completion: .finished)
                    self.isFinished = true
                }
            }
        }
        task(promise)
    }
}
