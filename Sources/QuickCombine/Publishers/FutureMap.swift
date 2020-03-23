//
//  FutureMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publishers {
    
    /// A publisher that eventually transforms each element from the upstream publisher into a single value with a provided promise closure.
    ///
    /// - Important: Each upstream element may only invoke a promise closure once. Any subsequent invocations of the promise closure will be ignored.
    struct FutureMap<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure
        
        /// A type that represents a closure to invoke in the future when an element is available.
        ///
        /// The promise closure receives one paramater: a single element published by a `FutureMap` publisher.
        public typealias Promise = (Output) -> Void
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that asynchronously transforms all upstream elements using a promise closure that can be invoked only once. Any subsequent invocations of the promise closure will be ignored.
        public let transform: (Upstream.Output, Promise) -> Void
        
        public init(upstream: Upstream, transform: @escaping (_ value: Upstream.Output, _ promise: @escaping Promise) -> Void) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap { value in
                    Future<Output, Failure> { promise in
                        self.transform(value) { promise(.success($0)) }
                    }
                }
                .subscribe(subscriber)
        }
    }
}
