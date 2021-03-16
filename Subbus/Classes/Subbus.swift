//
//  Subbus.swift
//
//  Created by Alex Larson on 8/21/18.
//  Edited by Cole Kainz on 12/21/18.
//  Copyright © 2018 Myriad Mobile. All rights reserved.
//

import Foundation

/// The protocol defining the basic capabilities of Subbus.
protocol SubbusProtocol {
    /// Adds a new subscription to Subbus with the specified listener ID and event type.
    ///
    /// If the `id` property is a class and it is not retained (ARC disposes of the object), Subbus will automatically remove any subscriptions for that `id`.
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  Used for unregistering.  Can be `Any` type, but classes and primitives are recommended.  Arrays, structs, etc are supported, but keep in mind they're passed as values.  If your struct/array/etc changes, this means it's a different identifier, similar to a string or integer.
    ///     - event: The event type to register the subscriber to.  Normally this is a class with no parent class, but there are special event types available.  See the Subbus docs.
    ///     - replace: Whether this event should replace a previous subscription with the same `id` and `event`.
    ///     - callback: The handler block for when the event is `Post`ed.
    static func addSubscription<I, T>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> Void)
    
    /// Posts a `PersistentEvent` to the subscribed receivers.
    ///
    /// Parameters:
    ///     - event: The event to be posted.
    static func post<T>(event: T)
    
    /// Unsubscribes a listener from further events of the specified type.
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  This is the same as used for subscribing.
    ///     - event: The event type to unsubscribe from.
    static func unsubscribe<I, T>(id: I, event: T.Type)
    
    /// Unsubscribes a listener from all further events.
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  This is the same as used for subscribing.
    static func unsubscribe<I>(id: I)
    
    /// Unsubscribes all listeners of the specified event type.
    ///
    /// Parameters:
    ///     - event: The event type from which all observers of this event will be unsubscribed.
    
    static func unsubscribe<T>(event: T.Type)
    
    /// Whether Subbus should log subscription and event posts to the console log for debugging purposes.
    static var logToConsole: Bool { get set }
}

/// A convenience extension to add shortened functions to the `SubbusProtocol`.
extension SubbusProtocol {
    /// Adds a new subscription to Subbus with the specified listener ID and event type.
    ///
    /// If the `id` property is a class and it is not retained (ARC disposes of the object), Subbus will automatically remove any subscriptions for that `id`.
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  Used for unregistering.  Can be `Any` type, but classes and primitives are recommended.  Arrays, structs, etc are supported, but keep in mind they're passed as values.  If your struct/array/etc changes, this means it's a different identifier, similar to a string or integer.
    ///     - event: The event type to register the subscriber to.  Normally this is a class with no parent class, but there are special event types available.  See the Subbus docs.
    ///     - callback: The handler block for when the event is `Post`ed.
    public static func addSubscription<I, T>(id: I, event: T.Type, callback: @escaping (T) -> Void) {
        addSubscription(id: id, event: event, replace: false, callback: callback)
    }
}

/// Conformance to the `SubbusProtocol`.
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
    
    internal static func addSubscription(_ subscription: Subscription, replace: Bool) {
        clearInvalidSubscriptions()
        
        if replace {
            subscriptions.removeAll(where: { $0.matches(subscription) })
        }
        
        subscriptions.append(subscription)
    }
    
    //Fire
    public static func post<T>(event: T) {
        clearInvalidSubscriptions()
        
        let eventType = String(reflecting: T.self)
        
        for subscription in subscriptions.filter({ $0.eventType == eventType }) {
            guard let handler = subscription.handler as? ((T) -> Void) else { continue }
            handler(event)
            log("Posted event to listener for identifier: \"\(String(describing: subscription.identifier))\"")
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
    
    public static func unsubscribe<T>(event: T.Type) {
        let eventType = String(reflecting: T.self)
        subscriptions.removeAll(where: { $0.matches(eventType: eventType) })
    }
}

extension Subbus {
    internal static func stringFor(id: Any) -> String? {
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
    
    internal static func log(_ message: String, force: Bool = false) {
        guard logToConsole || force else { return }
        print("Subbus: \(message)")
    }
    
    internal static func clearInvalidSubscriptions() {
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
    var identifierString: String = ""
    var eventType: String
    var handler: Any
    
    init?(identifier: Any, eventType: String, handler: Any) {
        self.eventType = eventType
        self.handler = handler
        
        let (id, message) = parseId(identifier)
        
        guard let parsedId = id, message == nil else {
            Subbus.log(message ?? "Subbus: Unable to recognize identifier", force: true)
            return nil
        }
        
        self.identifier = parsedId
        
        if let stringId = parsedId as? String {
            self.identifierString = stringId
        } else {
            self.identifierString = Subbus.stringFor(id: parsedId) ?? String(describing: parsedId)
        }
    }
    
    private func parseId(_ id: Any) -> (AnyObject?, String?) {
        let mirror = Mirror(reflecting: id)
        
        switch mirror.displayStyle {
        case .optional:
            var unwrapped: Any? = nil
            if mirror.children.count > 0 {
                (_, unwrapped) = mirror.children.first!
            }
            
            guard let id = unwrapped else {
                return (nil, "Subscribe - identifier is nil")
            }
            return parseId(id)
        case .struct, .enum, .tuple, .collection, .dictionary, .set, .none:
            guard let id = Subbus.stringFor(id: id) else {
                return (nil, "Subscribe - unabled to create string representation for Identifier")
            }
            
            return (id as AnyObject, nil)
        case .class:
            return (id as AnyObject, nil)
        case .some(let thing):
            return (nil, "Subscribe - identifier is unrecognizable: \(thing)")
        }
    }
    
    func matches(identifier otherId: Any?) -> Bool {
        let (parsedId, _) = parseId(otherId as Any)
        if let id = identifier as? String, let otherId = parsedId as? String {
            return id == otherId
        } else if let id = identifier, let otherId = parsedId {
            return "\(Unmanaged.passUnretained(id as AnyObject).toOpaque())" == "\(Unmanaged.passUnretained(otherId as AnyObject).toOpaque())"
        } else {
            return String(describing: identifier) == String(describing: otherId)
        }
    }
    
    func matches(eventType otherEventType: String) -> Bool {
        return eventType == otherEventType
    }
    
    func matches(identifier otherId:Any?, eventType otherEventType: String) -> Bool {
        guard matches(identifier: otherId) else { return false }
        guard matches(eventType: otherEventType) else { return false }
        return true
    }
    
    func matches(_ other: Subscription) -> Bool {
        return matches(identifier: other.identifier, eventType: other.eventType)
    }
}
