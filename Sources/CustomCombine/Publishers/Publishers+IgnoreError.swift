//
//  Publishers+IgnoreError.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine


@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers {
    
    /// A publisher that ignores all upstream errors, but passes along upstream elements.
    public struct IgnoreError<Upstream>: Publisher where Upstream: Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher publishes.
        public typealias Failure = Never
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Publishers.IgnoreError<Upstream>.Failure == S.Failure, Publishers.IgnoreError<Upstream>.Output == S.Input {
            upstream
                .catch { _ -> Empty<Output, Never> in
                    return Empty()
                }
                .subscribe(subscriber)
        }
    }
}
