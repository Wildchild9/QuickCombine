//
//  Publisher+passthroughAssign.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine
import SwiftUI

public extension Publisher {
    /// Assigns each element from the upstream publisher to a property on an object.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property on `object` to assign to.
    ///   - object: The object on which to assign the value.
    /// - Returns: A publisher that immediately emits elements from the upstream publisher as they are produced.
    func passthroughAssign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> Publishers.Passthrough<Self> {
        Publishers.Passthrough(upstream: self) { value in
            root[keyPath: keyPath] = value
        }
    }

    /// Assigns a property of each element from the upstream publisher to a property on an object.
    ///
    /// - Parameters:
    ///   - sourceKeyPath: The key path of the property on upstream elements to assign.
    ///   - targetKeyPath: The key path of the property on `object` to assign to.
    ///   - object: The object on which to assign the property of the value.
    /// - Returns: A publisher that immediately emits elements from the upstream publisher as they are produced.
    func passthroughAssign<Value, Root>(_ sourceKeyPath: KeyPath<Output, Value>, to targetKeyPath: ReferenceWritableKeyPath<Root, Value>, on object: Root) -> Publishers.Passthrough<Self> {
        Publishers.Passthrough(upstream: self) { value in
            object[keyPath: targetKeyPath] = value[keyPath: sourceKeyPath]
        }
    }
}

public extension Publisher {
    /// Assigns each element from the upstream publisher to a binding.
    ///
    /// - Parameter binding: The binding on which to assign the value.
    /// - Returns: A publisher that immediately emits elements from the upstream publisher as they are produced.
    func passthroughAssign(to binding: Binding<Output>) -> Publishers.Passthrough<Self> {
        Publishers.Passthrough(upstream: self) { value in
            binding.wrappedValue = value
        }
    }
    
    /// Assigns a property of each element from the upstream publisher to a binding.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property on upstream elements to assign.
    ///   - binding: The binding on which to assign the value.
    /// - Returns: A publisher that immediately emits elements from the upstream publisher as they are produced.
    func passthroughAssign<T>(_ keyPath: KeyPath<Output, T>, to binding: Binding<T>) -> Publishers.Passthrough<Self> {
        Publishers.Passthrough(upstream: self) { value in
            binding.wrappedValue = value[keyPath: keyPath]
        }
    }
}
