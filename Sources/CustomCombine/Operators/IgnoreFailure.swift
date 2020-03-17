//
//  IgnoreFailure.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    
    /// Ignores all upstream errors, but passes along upstream elements.
    ///
    /// The failure type of this publisher is `Never`.
    /// - Returns: A publisher that ignores all upstream errors.
    func ignoreFailure() -> Publishers.IgnoreFailure<Self> {
        return Publishers.IgnoreFailure(upstream: self)
    }
    
    /// Ignores all upstream errors, but passes along upstream elements.
    ///
    /// The failure type of this publisher is `Never`.
    /// - Returns: A publisher that ignores all upstream errors.
    func ignoreFailure(_ handler: @escaping (_ error: Failure) -> Void) -> Publishers.IgnoreFailure<Self> {
        return Publishers.IgnoreFailure(upstream: self, handler: handler)
    }
    
}


