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
    /// - Parameter error: The error to use when replacing `nil`.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided error.
    func replaceNil(with error: Failure) -> Publishers.TryMap<Self, Output.Wrapped> {
        tryMap { value in
            guard let unwrappedValue = value.asOptional else {
                throw error
            }
            return unwrappedValue
        }
    }
}
