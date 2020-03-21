//
//  Publisher+assign.swift
//  
//
//  Created by Noah Wilder on 2020-03-20.
//

import Combine

public extension Publisher where Failure == Never {
    /// Assigns a property of each element from the upstream publisher to a property on an object.
    ///
    /// - Parameters:
    ///   - sourceKeyPath: The key path of the property on upstream elements to assign.
    ///   - targetKeyPath: The key path of the property on `object` to assign to.
    ///   - object: The object on which to assign the property of the value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func assign<Value, Root>(_ sourceKeyPath: KeyPath<Output, Value>, to targetKeyPath: ReferenceWritableKeyPath<Root, Value>, on object: Root) -> AnyCancellable {
        self
            .map(sourceKeyPath)
            .assign(to: targetKeyPath, on: object)
    }
    
}

#if canImport(SwiftUI)
import SwiftUI
public extension Publisher where Failure == Never {
    /// Assigns each element from the upstream publisher to a binding.
    ///
    /// - Parameter binding: The binding on which to assign the value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func assign(to binding: Binding<Output>) -> AnyCancellable {
        sink { value in
            binding.wrappedValue = value
        }
    }
    
    /// Assigns a property of each element from the upstream publisher to a binding.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property on upstream elements to assign.
    ///   - binding: The binding on which to assign the value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func assign<T>(_ keyPath: KeyPath<Output, T>, to binding: Binding<T>) -> AnyCancellable {
        sink { value in
            binding.wrappedValue = value[keyPath: keyPath]
        }
    }
}

#endif
