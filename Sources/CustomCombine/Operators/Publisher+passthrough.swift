//
//  Publisher+passthrough.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    
    /// Performs a closure with all elements of the upstream publisher.
    /// - Parameter receiveOutput: A closure to invoke with each upstream element.
    /// - Returns: A publisher with that immediately emits elements from the upstream publisher as they are produced.
    func passthrough(_ receiveOutput: @escaping (Output) -> Void) -> Publishers.Passthrough<Self> {
        Publishers.Passthrough(upstream: self, receiveValue: receiveOutput)
    }
}
