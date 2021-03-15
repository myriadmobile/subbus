//
//  Subbus.swift
//
//  Created by Alex Larson on 8/21/18.
//  Edited by Cole Kainz on 12/21/18.
//  Copyright © 2018 Myriad Mobile. All rights reserved.
//

import Foundation

public class PersistentEvent {
    public enum HandlerResult {
        case handledSuccessfully
        case failed
    }
    
    public enum PersistanceRule {
        // If a subscriber returns .handledSuccessfully, no other subscribers will receive it
        case clearImmediately
        // If a subscriber returns .handledSuccessfully, only existing subscribers will receive the event, then it will be cleared
        case clearAfterAllCurrentSubscribersNotified
        // Event will never be cleared, regardless of what subscribers return
        case neverClear
    }
    
    var persistanceRule: PersistanceRule
    
    init(persistanceRule: PersistanceRule) {
        self.persistanceRule = persistanceRule
    }
}

protocol SubbusProtocol {
    static func addSubscription<I, T>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> Void)
    static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> PersistentEvent.HandlerResult)
    static func post<T>(event: T)
    static func unsubscribe<I, T>(id: I, event: T.Type)
    static func unsubscribe<I>(id: I)
    static var logToConsole: Bool { get set }
}

extension SubbusProtocol {
    public static func addSubscription<I, T>(id: I, event: T.Type, callback: @escaping (T) -> Void) {
        addSubscription(id: id, event: event, replace: false, callback: callback)
    }
    
    public static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, callback: @escaping (T) -> PersistentEvent.HandlerResult) {
        addSubscription(id: id, event: event, replace: false, callback: callback)
    }
}

public class Subbus: SubbusProtocol {
    //State
    static var logToConsole: Bool = false
    internal static var subscriptionsByEventType = [String: [Subscription]]()
    internal static var unhandledEvents = [PersistentEvent]()
    
    //Subscribe
    //TODO: Keep an eye out for a compile-time error to enforce non-optional ids. Optional<Wrapped> is a type and thus the language doesn't seem to support that :(
    public static func addSubscription<I, T>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> Void) {
        //Verify data
        guard !(id is OptionalProtocol) else { log("Subscribe - ID cannot be an Optional type.", force: true); return }
        guard let identifier = stringFor(id: id) else { log("Subscribe - String representation of ID is empty.", force: true); return }
        let eventType = String(reflecting: T.self)
        
        //Register listener
        var subscriptions = replace ? [] : (subscriptionsByEventType[eventType] ?? [])
        subscriptions.append(Subscription(identifierKey: identifier, handler: callback))
        subscriptionsByEventType[eventType] = subscriptions

        //Log
        log("Registered listener for identifier \"\(identifier)\"")
    }
    
    public static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> PersistentEvent.HandlerResult) {
        //Verify data
        guard !(id is OptionalProtocol) else { log("Subscribe - ID cannot be an Optional type.", force: true); return }
        guard let identifier = stringFor(id: id) else { log("Subscribe - String representation of ID is empty.", force: true); return }
        let eventType = String(reflecting: T.self)
        
        //Register listener
        var subscriptions = replace ? [] : (subscriptionsByEventType[eventType] ?? [])
        subscriptions.append(Subscription(identifierKey: identifier, handler: callback))
        subscriptionsByEventType[eventType] = subscriptions
        
        // Post existing events to this new subscription
        // TODO we should thread this (not the actual posting, but just let the current thread release before sorting through unhandled)
        for index in stride(from: unhandledEvents.count - 1, through: 0, by: -1)  {
            guard let unhandledEvent = unhandledEvents[index] as? T else { continue }
            
            let result = callback(unhandledEvent)
            
            if result == .handledSuccessfully {
                switch unhandledEvent.persistanceRule {
                case .clearImmediately:
                    fallthrough
                case .clearAfterAllCurrentSubscribersNotified:
                    unhandledEvents.remove(at: index)
                    
                case .neverClear:
                    continue
                }
            }
        }
        
        log("Registered listener for identifier \"\(identifier)\"")
    }
    
    //Fire
    public static func post<T>(event: T) {
        let eventType = String(reflecting: T.self)
        
        for subscription in subscriptionsByEventType[eventType] ?? [] {
            guard let handler = subscription.handler as? ((T) -> Void) else { continue }
            handler(event)
            log("Posted event to listener for identifier: \"\(subscription.identifierKey)\"")
        }
        
        log("Posted event for type: \"\(eventType)\"")
    }
    
    public static func post<T: PersistentEvent>(event: T) {
        let eventType = String(reflecting: T.self)
        var handled = false
        
        iteration: for subscription in subscriptionsByEventType[eventType] ?? [] {
            guard let handler = subscription.handler as? ((T) -> PersistentEvent.HandlerResult) else { continue }
            let result = handler(event)
            log("Posted event to listener for identifier: \"\(subscription.identifierKey)\"")
            
            handled = handled || (result == .handledSuccessfully)
            
            if handled {
                switch event.persistanceRule {
                case .clearImmediately:
                    break iteration
                    
                case .clearAfterAllCurrentSubscribersNotified:
                    continue
                    
                case .neverClear:
                    handled = false
                    continue
                }
            }
        }
        
        if !handled {
            unhandledEvents.insert(event, at: 0)
        }
        
        log("Posted event for type: \"\(eventType)\"")
    }

    //Unsubscribe
    public static func unsubscribe<I, T>(id: I, event: T.Type) {
        //Verify data
        guard !(id is OptionalProtocol) else { log("Unsubscribe - ID cannot be an Optional type.", force: true); return }
        guard let identifier = stringFor(id: id) else { log("Unsubscribe - String representation of ID is empty.", force: true); return }
        let eventType = String(reflecting: T.self)

        //Unsubscribe Listeners
        var subscriptions = subscriptionsByEventType[eventType] ?? []
        subscriptions.removeAll(where: { $0.identifierKey == identifier })
        subscriptionsByEventType[eventType] = subscriptions

        log("Unegistered listener for identifier \"\(identifier)\"")
    }

    public static func unsubscribe<I>(id: I) {
        //Verify data
        guard !(id is OptionalProtocol) else { log("Unsubscribe - ID cannot be an Optional type.", force: true); return }
        guard let identifier = stringFor(id: id) else { log("Unsubscribe - String representation of ID is empty.", force: true); return }
        
        for (key, value) in subscriptionsByEventType {
            var subscriptions = value
            subscriptions.removeAll(where: { $0.identifierKey == identifier })
            subscriptionsByEventType[key] = subscriptions
        }
        
        log("Unegistered listener for identifier \"\(identifier)\"")
    }
    
    //Misc
    static func log(_ message: String, force: Bool = false) {
        guard logToConsole || force else { return }
        print("Subbus: \(message)")
    }
    
    static func stringFor(id: Any) -> String? {
        var valString = "" //Value or pointer
        let idType = type(of: id)
        
        //Get the right string type; objects need memory address and primitives just need value.
        if idType is AnyClass {
            valString = "\(Unmanaged.passUnretained(id as AnyObject).toOpaque())"
        } else {
            valString = "\(id)"
        }
        
        //Ensure that the idString is valid
        guard valString.isEmpty == false else { return nil }
        guard valString != "nil" else { return nil }
        
        return "\(idType)-\(valString)"
    }
    
    internal static func clearHistory() {
        unhandledEvents = []
        log("WARNING: cleared event history!  This function was made for unit testing, please don't use it.", force: true)
    }
    
    internal static func clearSubscribers() {
        subscriptionsByEventType = [:]
        log("WARNING: cleared subscriber cache!  This function was made for unit testing, please don't use it.", force: true)
    }
}

//An easy way to check if something is optional without knowing the Wrapped type
internal protocol OptionalProtocol {}
extension Optional: OptionalProtocol {}

internal struct Subscription {
    var identifierKey: String
    var handler: Any
}
