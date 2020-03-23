# QuickCombine

![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg) ![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg) ![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)  [![License](http://img.shields.io/:license-MIT-blue.svg)](http://doge.mit-license.org)

QuickCombine provides additional operators and publishers to boost your productivity with Apple's [Combine framework](https://developer.apple.com/documentation/combine).

## Compatibility

A minimum of **Swift 5.1** is required to build QuickCombine (Xcode 11).


## Overview

- **[Operators](#operators)**
  - Asynchronous Mapping:
    - [`futureMap`](#futuremap)
    - [`tryFutureMap`](#tryfuturemap)
    
  - Convenience Overloads:
    - [`compactMap`](#compactmap)
    - [`replaceNil`](#replacenil)
    - [`assign`](#assign)
    
  - Other: 
    - [`ignoreFailure`](#ignorefailure)
    - [`eraseToAnyError`](#erasetoanyerror)
    - [`passthrough`](#passthrough)
    - [`passthroughAssign`](#passthroughassign)
  

## Operators

- #### `futureMap`
  This operator asynchronously maps each element for the upstream publisher to one output using promises. Upon the first promise being called, `futureMap` will ignore all subsequent promises and pass a finished completion state downstream. Since `futureMap` cannot produce any errors, its error type is `Never`. For an operator with the same functionality as `futureMap` but with error propagation, see [`tryFutureMap`](#tryfuturemap).

  In the following example, `futureMap` is used to retrieve the value at a specific location in a database.
  ```swift
  Just("Some/Database/Path")
      .futureMap { path, promise in
          getValueInDatabase(at: path) { value in
              promise((path, value))
          }
      }
      .sink { (path, value) in
          print("The value of \(path) is \(value)")  // Prints the location of the value and the value itself
      }
  ```

- #### `tryFutureMap`
  This operator is the same as `futureMap` with one notable exception, `tryFutureMap` allows errors to be propagated downstream. Because of this, `tryFutureMap`'s promise takes a single argument of type `Result<Output, Upstream.Failure>`.

  In the following example, `tryFutureMap` is used to retrieve the value at a specific location in a database, passing any errors downstream. If the request succeeds, the value is printed, otherwise, the error message is printed.
  ```swift
  Just("Some/Database/Path")
      .setFailureType(to: DatabaseError.self)
      .tryFutureMap { path, promise in
      retrieveDatabaseValue(at: path) { result, error in
              if let error = error {
                  promise(.failure(error))
              } else {
                  promise(.success(result!))
              }
          }
      }
      .sink(receiveCompletion: { completion in
          if case let .failure(error) = completion {
              print(error.localizedDescription)
          }
      }, receiveValue: { value in
          print(value)
      })
  ```
  In the case that throwing functions are used within the body of `tryFutureMap`, the `Failure` type of the resultant publisher will be `Error`.

  ----

- #### `compactMap`

- #### `replaceNil`

- #### `assign`

  ----

- #### `ignoreFailure`

- #### `eraseToAnyError`

- #### `passthrough`

- #### `passthroughAssign`

