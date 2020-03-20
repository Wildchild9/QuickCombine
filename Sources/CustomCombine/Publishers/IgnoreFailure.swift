//
//  IgnoreFailure.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine


@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    
    /// A publisher that ignores all upstream errors, but passes along upstream elements.
    struct IgnoreFailure<Upstream>: Publisher where Upstream: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Never
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The handler for upstream errors.
        public let handler: (Upstream.Failure) -> Void
        
        public init(upstream: Upstream) {
            self.upstream = upstream
            self.handler = { _ in }
        }
        
        public init(upstream: Upstream, handler: @escaping (_ error: Upstream.Failure) -> Void) {
            self.upstream = upstream
            self.handler = handler
        }
       
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .catch { error -> Empty<Output, Never> in
                    self.handler(error)
                    return Empty()
                }
                .subscribe(subscriber)
        }
    }
}
