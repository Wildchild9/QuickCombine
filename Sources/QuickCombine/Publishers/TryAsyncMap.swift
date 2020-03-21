//
//  TryAsyncMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publishers {
    
    /// A publisher that asyncronously transforms all elements from the upstream publisher or produces errors using promises.
    struct TryAsyncMap<Upstream, Output>: Publisher where Upstream: Publisher {
        
        public typealias Failure = Upstream.Failure
        
        /// A type that represents a closure to invoke in the future, when an element or error is available.
        ///
        /// The promise closure receives one parameter: a `Result` that contains either a single element published by a `TryAsyncMap` publisher, or an error.
        public typealias Promise = (Result<Output, Failure>) -> Void
                
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that asyncronously transforms upstream elements using a promise closure that can be invoked multiple times.
        public let transform: (Upstream.Output, Promise) -> Void
        
        public init(upstream: Upstream, transform: @escaping (_ value: Upstream.Output, _ promise: Promise) -> Void) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap { value in
                    TryAsync { promise in
                        self.transform(value, promise)
                    }
            }
            .subscribe(subscriber)
        }
    }
}


extension Publishers.TryAsyncMap where Failure == Error {
    public init(upstream: Upstream, transform: @escaping (_ value: Upstream.Output, _ promise: Promise) throws -> Void) {
        self.upstream = upstream
        self.transform = { value, promise in
            do {
                try transform(value, promise)
            } catch {
                promise(.failure(error))
            }
        }
    }
}
