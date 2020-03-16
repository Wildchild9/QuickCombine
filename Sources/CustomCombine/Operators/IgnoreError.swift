//
//  IgnoreError.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    /// Ignores all upstream errors, but passes along upstream elements.
    ///
    /// The failure type of this publisher is `Never`.
    /// - Returns: A publisher that ignores all upstream errors.
    func ignoreError() -> Publishers.IgnoreError<Self> {
        return Publishers.IgnoreError(upstream: self)
    }
}


