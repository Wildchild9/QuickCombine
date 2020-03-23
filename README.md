# QuickCombine

![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg) ![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg) ![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)  [![License](http://img.shields.io/:license-MIT-blue.svg)](http://doge.mit-license.org)

QuickCombine provides additional operators and publishers to boost your productivity with Apple's [Combine framework](https://developer.apple.com/documentation/combine).

## Compatibility

A minimum of **Swift 5.1** is required to build QuickCombine (Xcode 11).


## Overview

- **[Publishers](#publishers)**
  - [`Async`](#async)
  - [`TryAsync`](#tryasync)
  
- **[Operators](#operators)**
  - Asynchronous Mapping:
    - [`futureMap`](#futuremap)
    - [`tryFutureMap`](#tryfuturemap)
    - [`asyncMap`](#asyncmap)
    - [`tryAsyncMap`](#tryasyncmap)
    
  - Convenience Overloads:
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

### Asynchronous Mapping
QuickCombine provides 4 operators for asynchronous mapping operations, `futureMap`, `tryFutureMap`, `asyncMap`, and `tryAsyncMap`. The following tables compares the features of the 4 operators.

| Features | [`futureMap`](#futuremap) | [`tryFutureMap`](#tryfuturemap) | [`asyncMap`](#asyncmap) | [`tryAsyncMap`](#tryasyncmap) |
| :--- | :---: | :---: | :---: | :---: |
| Supports asynchronous execution | ✅ | ✅ | ✅ | ✅ |
| Supports error propogation | ❌ | ✅ | ❌ | ✅ |
| Produces only one downstream output for each upstream element (one to one) | ✅ | ✅ | ❌ | ❌ |
| Can produce multiple downstream outputs for each upstream element (one to many) | ❌ | ❌ | ✅ | ✅ |

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

- #### `asyncMap`
  This operator allows you to asynchronously map elements from an upstream publisher using promises. For each upstream output, this publisher may produce multiple outputs. Because of the potential to produce any number of outputs, `asyncMap` never passes on a completion state and as such must explicitly be cancelled. Since `asyncMap` cannot produce any errors, its error type is `Never`. For the same functionality with error propagation, see [`tryAsyncMap`](#tryasyncmap).

  In the following example, `asyncMap` is used to asynchronously pass a value at a path in a database downstream whenever it changes.
  ```swift
  Just("Some/Database/Path") 
      .asyncMap { path, promise in
          observeValueChanged(at: path, onValueChanged: { newValue in
              promise(newValue)
          })
      }
      .sink { newValue in
          print("Value changed to: \(newValue)")
      }
  ```

- #### `tryAsyncMap`
  This operator is the same as `asyncMap` with one notable exception, `tryAsyncMap` allows errors to be propagated downstream. Because of this, `tryAsyncMap`'s promise takes a single argument of type `Result<Output, Upstream.Failure>`.

  In the following example, `tryAsyncMap` is used to asynchronously pass the value at a path in a database, or an error if the request fails, downstream whenever it changes.
  ```swift
  Just("Some/Database/Path") 
      .tryAsyncMap { path, promise in
          observeValueChanged(at: path, onValueChanged: { possibleNewValue in
              if let newValue = possibleNewValue {
                  promise(.success(newValue))
              } else {
                  promise(.failure(DatabaseError.couldNotAccessValue))
              }
          })
      }
      .sink(receiveCompletion: { completion in
          if case .failure(.couldNotAccessValue) = completion {
              print("Could not access changed value")
          }
      }, receiveValue: { newValue in 
          print("Value changed to: \(newValue)")
      })
  ```
  In the case that throwing functions are used within the body of `tryAsyncMap`, the `Failure` type of the resultant publisher will be `Error`.

  ----

- #### `compactMap`

- #### `replaceNil`

- #### `assign`

- #### `ignoreFailure`

- #### `eraseToAnyError`

- #### `passthrough`

- #### `passthroughAssign`

