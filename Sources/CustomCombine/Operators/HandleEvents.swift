//
//  SinkError.swift
//  
//
//  Created by Noah Wilder on 2020-03-16.
//

import Combine
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers.HandleEvents {
    enum Event {
        case receiveSubscription
        case receiveOutput
        case receiveCompletion
        case receiveCancel
        case receiveRequest
    }
}
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    func handleSubscription(_ onReceiveSubscription: @escaping (Subscription) -> Void) -> Publishers.HandleEvents<Self> {
        return handleEvents(receiveSubscription: onReceiveSubscription)
    }
    func handleOutput(_ onReceiveOutput: @escaping (Output) -> Void) -> Publishers.HandleEvents<Self> {
        return handleEvents(receiveOutput: onReceiveOutput)
    }
    func handleCompletion(_ onReceiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) -> Publishers.HandleEvents<Self> {
        return handleEvents(receiveCompletion: onReceiveCompletion)
    }
    func handleCancel(_ onReceiveCancel: @escaping () -> Void) -> Publishers.HandleEvents<Self> {
        return handleEvents(receiveCancel: onReceiveCancel)
    }
    func handleRequest(_ onReceiveRequest: @escaping (Subscribers.Demand) -> Void) -> Publishers.HandleEvents<Self> {
        return handleEvents(receiveRequest: onReceiveRequest)
    }
    func handleError(_ onReceiveError: @escaping (Failure) -> Void) -> Publishers.HandleEvents<Self> {
        return handleEvents(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                onReceiveError(error)
            }
        })
    }
}

