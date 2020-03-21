//
//  Publisher+eraseToAnyError.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    /// Changes the `Failure` type of the upstream publisher to `Error`.
    /// 
    /// - Returns: A publisher with a type-erased `Failure` type of `Error`.
    func eraseToAnyError() -> Publishers.MapError<Self, Error> {
        return mapError { $0 as Error }
    }
}
