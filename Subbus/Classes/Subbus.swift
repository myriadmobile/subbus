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
    internal static var subscriptions = [Subscription]()
    internal static var unhandledEvents = [PersistentEvent]()
    
    //Subscribe
    public static func addSubscription<I, T>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> Void) {
        let eventType = String(reflecting: T.self)
        
        guard let subscription = Subscription(identifier: id, eventType: eventType, handler: callback) else { return }
        addSubscription(subscription, replace: replace)

        log("Registered listener for identifier \"\(stringFor(id: id) ?? String(describing: id))\"")
    }
    
    public static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> PersistentEvent.HandlerResult) {
        let eventType = String(reflecting: T.self)
        
        //Register listener
        guard let subscription = Subscription(identifier: id, eventType: eventType, handler: callback) else { return }
        addSubscription(subscription, replace: replace)
        
        // Post existing events to this new subscription
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
        
        
        log("Registered listener for identifier \"\(stringFor(id: id) ?? String(describing: id)))\"")
    }
    
    private static func addSubscription(_ subscription: Subscription, replace: Bool) {
        cleanup()
        
        if replace {
            subscriptions.removeAll(where: { $0.matches(subscription) })
        }
        
        subscriptions.append(subscription)
    }
    
    //Fire
    public static func post<T>(event: T) {
        cleanup()
        
        let eventType = String(reflecting: T.self)
        
        for subscription in subscriptions.filter({ $0.eventType == eventType }) {
            guard let handler = subscription.handler as? ((T) -> Void) else { continue }
            handler(event)
            log("Posted event to listener for identifier: \"\(String(describing: subscription.identifier))\"")
        }
        
        log("Posted event for type: \"\(eventType)\"")
    }
    
    public static func post<T: PersistentEvent>(event: T) {
        cleanup()
        
        let eventType = String(reflecting: T.self)
        var handled = false
        
        iteration: for subscription in subscriptions.filter({ $0.eventType == eventType }) {
            guard let handler = subscription.handler as? ((T) -> PersistentEvent.HandlerResult) else { continue }
            let result = handler(event)
            log("Posted event to listener for identifier: \"\(String(describing: subscription.identifier))\"")

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
        let eventType = String(reflecting: T.self)

        subscriptions.removeAll(where: { $0.matches(identifier: id, eventType: eventType) })

        log("Unegistered listener for identifier \"\(id)\" event \"\(eventType)\"")
    }

    public static func unsubscribe<I>(id: I) {
        subscriptions.removeAll(where: { $0.matches(identifier: id) })
        
        log("Unegistered listener for identifier \"\(id)\"")
    }
}

extension Subbus {
    internal static func log(_ message: String, force: Bool = false) {
        guard logToConsole || force else { return }
        print("Subbus: \(message)")
    }
    
    private static func cleanup() {
        subscriptions.removeAll(where: { $0.identifier == nil })
    }
    
    internal static func clearHistory() {
        unhandledEvents = []
        log("WARNING: cleared event history!  This function was made for unit testing, please don't use it.", force: true)
    }
    
    internal static func clearSubscribers() {
        subscriptions = []
        log("WARNING: cleared subscriber cache!  This function was made for unit testing, please don't use it.", force: true)
    }
}

internal struct Subscription {
    weak var identifier: AnyObject?
    var eventType: String
    var handler: Any
    
    init?(identifier: Any, eventType: String, handler: Any) {
        var unwrapped: Any? = nil
        
        let mirror = Mirror(reflecting: identifier)
        if mirror.displayStyle != .optional {
            unwrapped = identifier
        } else if mirror.children.count > 0 {
            (_, unwrapped) = mirror.children.first!
        }
        
        guard let identifier = unwrapped else {
            Subbus.log("Subscribe - identifier is nil", force: true)
            return nil
        }
        
        self.identifier = identifier as AnyObject
        self.eventType = eventType
        self.handler = handler
    }
    
    func matches(identifier otherId: Any?) -> Bool {
        if let id = identifier {
            return "\(Unmanaged.passUnretained(id as AnyObject).toOpaque())" == "\(Unmanaged.passUnretained(otherId as AnyObject).toOpaque())"
        } else {
            return String(describing: identifier) == String(describing: otherId)
        }
    }
    
    func matches(identifier otherId:Any?, eventType otherEventType: String) -> Bool {
        guard matches(identifier: otherId) else { return false }
        return eventType == otherEventType
    }
    
    func matches(_ other: Subscription) -> Bool {
        return matches(identifier: other.identifier, eventType: other.eventType)
    }
}
