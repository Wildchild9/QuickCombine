//
//  Publisher+then.swift
//  
//
//  Created by Noah Wilder on 2020-03-23.
//

import Combine

public extension Publisher {
    /// Ignores all upstream elements, and upon a successful upstream completion, switches to a different provided publisher to emit elements downstream.
    ///
    /// - Parameter transform: A closure that produces a new publisher to emit elements downstream upon the successful completion of the upstream publisher.
    /// - Returns: A publisher that ignores all upstream elements and switches to a new publisher produced by the `transform` closure.
    func then<T>(_ transform: @escaping () -> T) -> Publishers.Then<Self, T> where T: Publisher, T.Failure == Failure {
        return Publishers.Then(upstream: self, transform: transform)
    }
    
    /// Ignores all upstream elements, and upon a successful upstream completion, switches to a different provided publisher to emit elements downstream.
    ///
    /// - Parameter transform: A closure that produces a new publisher to emit elements downstream upon the successful completion of the upstream publisher.
    /// - Returns: A publisher that ignores all upstream elements and switches to a new publisher produced by the `transform` closure.
    func then<T>(_ transform: @escaping () -> T) -> Publishers.Then<Publishers.MapError<Self, Error>, Publishers.MapError<T, Error>> where T: Publisher {
        return Publishers.Then(upstream: self.mapError { $0 as Error }) {
            transform()
                .mapError { $0 as Error }
        }
    }
    
    /// Ignores all upstream elements, and upon a successful upstream completion, switches to a different provided publisher to emit elements downstream.
    ///
    /// - Parameter transform: A closure that produces a new publisher to emit elements downstream upon the successful completion of the upstream publisher.
    /// - Returns: A publisher that ignores all upstream elements and switches to a new publisher produced by the `transform` closure.
    func then<T>(_ transform: @escaping () -> T) -> Publishers.Then<Publishers.MapError<Self, Error>, T> where T: Publisher, T.Failure == Error {
        return Publishers.Then(upstream: self.mapError { $0 as Error }, transform: transform)
    }
}

public extension Publisher where Failure == Error {
    /// Ignores all upstream elements, and upon a successful upstream completion, switches to a different provided publisher to emit elements downstream.
    ///
    /// - Parameter transform: A closure that produces a new publisher to emit elements downstream upon the successful completion of the upstream publisher.
    /// - Returns: A publisher that ignores all upstream elements and switches to a new publisher produced by the `transform` closure.
    func then<T>(_ transform: @escaping () -> T) -> Publishers.Then<Self, Publishers.MapError<T, Error>> where T: Publisher {
        return Publishers.Then(upstream: self) {
            transform()
                .mapError { $0 as Error }
        }
    }
}

public extension Publisher where Failure == Never {
    /// Ignores all upstream elements, and upon a successful upstream completion, switches to a different provided publisher to emit elements downstream.
    ///
    /// - Parameter transform: A closure that produces a new publisher to emit elements downstream upon the successful completion of the upstream publisher.
    /// - Returns: A publisher that ignores all upstream elements and switches to a new publisher produced by the `transform` closure.
    func then<T>(_ transform: @escaping () -> T) -> Publishers.Then<Publishers.SetFailureType<Self, T.Failure>, T> where T: Publisher {
        return Publishers.Then(upstream: self.setFailureType(to: T.Failure.self), transform: transform)
    }
}
