//
//  Publisher+compactMap.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher {
    /// Publishes the value of any optional key path that has a value.
    /// 
    /// - Parameter keyPath: The key path of a property on `Output`.
    /// - Returns: A publisher that republishes all non-`nil` values of the key path.
    func compactMap<T>(_ keyPath: KeyPath<Output, T?>) -> Publishers.CompactMap<Self, T> {
        return compactMap { $0[keyPath: keyPath] }
    }
}
