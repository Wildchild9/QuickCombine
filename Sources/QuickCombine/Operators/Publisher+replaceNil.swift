//
//  Publisher+replaceNil.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine

public protocol OptionalConvertible {
    associatedtype Wrapped
    var asOptional: Optional<Wrapped> { get }
}

extension Optional: OptionalConvertible {
    public var asOptional: Optional<Wrapped> { return self }
}


public extension Publisher where Output: OptionalConvertible {
    /// Replaces `nil` elements in the stream with the provided error.
    /// - Parameter error: The error with which to replace `nil` elements in the stream.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided error.
    func replaceNil(with error: Failure) -> Publishers.ReplaceNil<Self> {
        return Publishers.ReplaceNil(upstream: self, nilReplacementError: error)
    }
    
    /// Replaces `nil` elements in the stream with the provided error.
    /// - Parameter error: The error with which to replace `nil` elements in the stream.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided error.
    func replaceNil<T>(with error: T) -> Publishers.ReplaceNil<Publishers.MapError<Self, Error>> where T: Error {
        return Publishers.ReplaceNil(upstream: self.mapError { $0 as Error }, nilReplacementError: error)
    }
}

public extension Publisher where Output: OptionalConvertible, Failure == Error {
    /// Replaces `nil` elements in the stream with the provided error.
    /// - Parameter error: The error with which to replace `nil` elements in the stream.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided error.
    func replaceNil<T>(with error: T) -> Publishers.ReplaceNil<Self> where T: Error {
        return Publishers.ReplaceNil(upstream: self, nilReplacementError: error as Error)
    }
}

public extension Publisher where Output: OptionalConvertible, Failure == Never {
    /// Replaces `nil` elements in the stream with the provided error.
    /// - Parameter error: The error with which to replace `nil` elements in the stream.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided error.
    func replaceNil<T>(with error: T) -> Publishers.ReplaceNil<Publishers.SetFailureType<Self, T>> where T: Error {
        return Publishers.ReplaceNil(upstream: self.setFailureType(to: T.self), nilReplacementError: error)
    }
}
