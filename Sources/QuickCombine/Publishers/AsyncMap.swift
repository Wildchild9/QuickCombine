//
//  AsyncMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publishers {
    
    /// A publisher that asynchronously transforms all elements from the upstream publisher using promises.
    struct AsyncMap<Upstream, Output>: Publisher where Upstream: Publisher {
        
        public typealias Failure = Upstream.Failure
        
        /// A type that represents a closure to invoke in the future when an element is available.
        ///
        /// The promise closure receives one paramater: a single element published by a `AsyncMap` publisher.
        public typealias Promise = (Output) -> Void
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that asynchronously transforms upstream elements using a promise closure that that can be invoked multiple times.
        public let transform: (Upstream.Output, Promise) -> Void
        
        public init(upstream: Upstream, transform: @escaping (_ value: Upstream.Output, _ promise: Promise) -> Void) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap { value in
                    Async { promise in
                        self.transform(value, promise)
                    }
                    .setFailureType(to: Failure.self)
            }
            .subscribe(subscriber)
        }
    }
}
