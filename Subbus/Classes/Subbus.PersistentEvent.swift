//
//  Subbus.PersistentEvent.swift
//  Subbus
//
//  Created by Jangle's MacBook Pro on 3/15/21.
//

/// A special event type that Subbus will persist beyond `Post`ing the event.
public class PersistentEvent {
    /// The result returned by an event handler.
    public enum HandlerResult {
        /// Returned when the handler was able to successfully handle the event.
        case handledSuccessfully
        /// Returned when the handler was unable to process the event.
        case failed
    }
    
    /// The rule defining how the event will be persisted.
    ///
    /// For all rules, if no subscribers return .handledSuccessfully, the event will persist.
    /// The next subscriber to subscribe to that event will immediately receive the event.
    public enum PersistenceRule {
        /// If a subscriber returns .handledSuccessfully, no other subscribers will receive it.
        case clearImmediately
        /// If a subscriber returns .handledSuccessfully, only existing subscribers
        /// will receive the event, then it will be cleared.
        case clearAfterAllCurrentSubscribersNotified
        /// Event will *never* be cleared, regardless of what subscribers return.
        case neverClear
    }
    
    /// The event's persistence rule.
    var persistenceRule: PersistenceRule
    
    /// Initializer that requires a persistence rule.
    ///
    /// Parameters:
    ///     - persistenceRule: the rule of persistence.
    init(persistenceRule: PersistenceRule) {
        self.persistenceRule = persistenceRule
    }
}

/// The protocol defining the persistence capabilities added to Subbus.
protocol SubbusPersistentEventProtocol {
    /// Adds a new subscription to Subbus with a `PersistentEvent`.
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  Used for unregistering.
    ///     - event: The event type to register the subscriber to.  This class will be a subclass of `PersistentEvent`.
    ///     - replace: Whether this event should replace a previous subscription with the same `id` and `event`.
    ///     - callback: The handler block for when the event is `Post`ed.
    static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> PersistentEvent.HandlerResult)
    
    /// Posts a `PersistentEvent` to the subscribed receivers.
    ///
    /// Parameters:
    ///     - event: The event to be posted.
    static func post<T: PersistentEvent>(event: T)
}

/// A convenience extension to add shortened functions to the `SubbusPersistentEventProtocol`.
extension SubbusPersistentEventProtocol {
    /// Adds a new subscription to Subbus with a `PersistentEvent`.
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  Used for unregistering.
    ///     - event: The event type to register the subscriber to.
    ///     - callback: The handler block for when the event is `Post`ed.
    public static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, callback: @escaping (T) -> PersistentEvent.HandlerResult) {
        addSubscription(id: id, event: event, replace: false, callback: callback)
    }
}

/// Conformance to the `SubbusPersistentEventProtocol`.
extension Subbus: SubbusPersistentEventProtocol {
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
                switch unhandledEvent.persistenceRule {
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
    
    public static func post<T: PersistentEvent>(event: T) {
        clearInvalidSubscriptions()
        
        let eventType = String(reflecting: T.self)
        var handled = false
        
        iteration: for subscription in subscriptions.filter({ $0.eventType == eventType }) {
            guard let handler = subscription.handler as? ((T) -> PersistentEvent.HandlerResult) else { continue }
            let result = handler(event)
            log("Posted event to listener for identifier: \"\(String(describing: subscription.identifier))\"")

            handled = handled || (result == .handledSuccessfully)
            
            if handled {
                switch event.persistenceRule {
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
}
