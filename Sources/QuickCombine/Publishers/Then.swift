//
//  Then.swift
//  
//
//  Created by Noah Wilder on 2020-03-23.
//

import Combine

public extension Publishers {
    /// A publisher that ignores all upstream elements and uses a new publisher to emit elements downstream.
    struct Then<Upstream, NextPublisher>: Publisher where Upstream: Publisher, NextPublisher: Publisher, NextPublisher.Failure == Upstream.Failure {
        
        public typealias Failure = Upstream.Failure
        public typealias Output = NextPublisher.Output
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure from which a new publisher will be created that emits elements downstream upon receiving a successful completion for the upstream publisher.
        public let transform: () -> NextPublisher
        
        public init(upstream: Upstream, transform: @escaping () -> NextPublisher) {
            self.upstream = upstream
            self.nextPublisher = nextPublisher
        }
    
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            upstream
                .ignoreOutput()
                .flatMap { _ in
                    nextPublisher
                }
                .subscribe(subscriber)
        }
    }
}
