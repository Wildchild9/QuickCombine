# QuickCombine

![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg) ![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg) ![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)  [![License](http://img.shields.io/:license-MIT-blue.svg)](http://doge.mit-license.org)

QuickCombine provides additional operators and publishers to boost your productivity with Apple's [Combine framework](https://developer.apple.com/documentation/combine).

## Overview

- **[Publishers](#publishers)**
  - [`Async`](#async)
  - [`TryAsync`](#tryasync)
  
- **[Operators](#operators)**
  - Asynchronous:
    - [`asyncMap`](#asyncmap)
    - [`tryAsyncMap`](#tryasyncmap)
    - [`futureMap`](#futuremap)
    - [`tryFutureMap`](#tryfuturemap)
    
  - Overloads:
    - [`compactMap`](#compactmap)
    - [`replaceNil`](#replacenil)
    - [`assign`](#assign)
    
  - Other: 
    - [`ignoreFailure`](#ignorefailure)
    - [`eraseToAnyError`](#erasetoanyerror)
    - [`passthrough`](#passthrough)
    - [`passthroughAssign`](#passthroughassign)
  
## Publishers

#### `Async`
The `Async` publisher allows you to easily work with asynchronous code that can produce more than one value over time.
```swift
Async<String> { promise in
    promise("a")
    promise("b")
    promise("c")
}
.sink { value in 
    print(value)
}
    
// Prints: 
// "a"
// "b"
// "c"
```
This publisher can be particularly useful when writing Combine code for database observers, as it allows you to pass changes to your database over time downstream.

  ----
#### `TryAsync`

The `TryAsync` published is similar to the `Async` publisher, except its promise is a `Result`. This allows you to work with asynchronous code that can produce errors. 

In the following example, `someAsynchronousCallback` produces a closure of type `(_ result: String?, _ error: Error?) -> Void`. 
```swift
TryAsync<String, Error> { promise in
    someAsynchronousCallback { result, error in
        if let error = error {
            promise(.failure(error))
        } else {
            promise(.success(result!))
        }
    }
}
```

## Operators

#### `asyncMap`
#### `tryAsyncMap`
#### `futureMap`
#### `tryFutureMap`

#### `compactMap`
#### `replaceNil`
#### `assign`

#### `ignoreFailure`
#### `eraseToAnyError`
#### `passthrough`
#### `passthroughAssign`

