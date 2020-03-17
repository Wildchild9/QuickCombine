//
//  Publishers+IgnoreFailure.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine


@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    
    /// A publisher that ignores all upstream errors, but passes along upstream elements.
    struct IgnoreFailure<Upstream>: Publisher where Upstream: Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher publishes.
        public typealias Failure = Never
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
       
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .catch { _ -> Empty<Output, Never> in
                    return Empty()
                }
                .subscribe(subscriber)
        }
    }
}
