//
//  Subbus.PersistentEvent.swift
//  Subbus
//
//  Created by Jangle's MacBook Pro on 3/15/21.
//

/**
    A special event type that Subbus will persist beyond `Post`ing the event
 */
public class PersistentEvent {
    /**
     The result returned by an event handler
     */
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

protocol SubbusPersistentEventProtocol {
    static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, replace: Bool, callback: @escaping (T) -> PersistentEvent.HandlerResult)

}

extension SubbusPersistentEventProtocol {
    public static func addSubscription<I, T: PersistentEvent>(id: I, event: T.Type, callback: @escaping (T) -> PersistentEvent.HandlerResult) {
        addSubscription(id: id, event: event, replace: false, callback: callback)
    }
}

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
}
