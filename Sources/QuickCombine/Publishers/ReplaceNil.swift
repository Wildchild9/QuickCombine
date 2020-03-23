//
//  ReplaceNil.swift
//  
//
//  Created by Noah Wilder on 2020-03-23.
//

import Combine

public extension Publishers {
    /// A publisher that replaces `nil` elements from an upstream publisher with a provided error.
    struct ReplaceNil<Upstream>: Publisher where Upstream: Publisher, Upstream.Output: OptionalConvertible {
        public typealias Failure = Upstream.Failure
        
        public typealias Output = Upstream.Output.Wrapped
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The error with which to replace `nil` elements in the upstream publisher.
        public let nilReplacementError: Failure
        
        public init(upstream: Upstream, nilReplacementError: Failure) {
            self.upstream = upstream
            self.nilReplacementError = nilReplacementError
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap { value in
                    Future<Output, Failure> { promise in
                        if let value = value.asOptional {
                            promise(.success(value))
                        } else {
                            promise(.failure(self.nilReplacementError))
                        }
                    }
                }
                .subscribe(subscriber)
        }
    }
}
