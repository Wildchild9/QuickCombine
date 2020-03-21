//
//  Passthrough.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publishers {
    
    /// A publisher that performs a closure with the elements of an upstream publisher.
    struct Passthrough<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure that executes when the publisher receives a value from the upstream publisher.
        public let receiveValue: (Output) -> Void
        
        init(upstream: Upstream, receiveValue: @escaping (Output) -> Void) {
            self.upstream = upstream
            self.receiveValue = receiveValue
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .handleEvents(receiveOutput: receiveValue)
                .subscribe(subscriber)
        }
    }
}
