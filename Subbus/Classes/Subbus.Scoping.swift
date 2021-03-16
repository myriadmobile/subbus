//
//  Subbus.Scoping.swift
//  Pods-Subbus_Example
//
//  Created by Alex Larson on 2/6/20.
//

/// The protocol defining the scoping capabilities added to Subbus.
protocol SubbusScopingProtocol {
    /// Adds a new subscription to Subbus with a `ScopedEvent`.
    ///
    /// This scope limits the receivers of an event even further,
    /// allowing the same event to have further separation of types without defining multiple events.
    ///
    /// There is no easy way to unsubscribe from a particular scope by using ONLY the scope.
    /// I.e. there is no `unsubscribe(id:event:scope:)`.
    ///
    /// If you want to unsubscribe from with a particular scope - use a unique ID (for example - reuse the scope!).
    ///
    ///     let scope = "abc"
    ///     addSubscription(id: scope, MyEvent.self, limitedToScope: scope)
    ///     unsubscribe(id: scope, MyEvent.self)
    ///
    /// Parameters:
    ///     - id: The id of the subscriber to this event.  Used for unregistering.
    ///     - event: The event type to register the subscriber to.  This class will be a subclass of `ScopedEvent`.
    ///     - limitedToScope: The scope to subscribe to.  Cannot be `nil` or an `Optional` type.
    ///     - callback: The handler block for when the event is `Post`ed.
    static func addSubscription<S, I, T>(id: I, event: T.Type, limitedToScope scope: S, callback: @escaping (T) -> Void)
    
    /// Posts a `PersistentEvent` to the subscribed receivers.
    ///
    /// Parameters:
    ///     - event: The event to be posted.
    ///     - limitedToScope: The scope limitation for the posted event.  Cannot be `nil` or an `Optional` type.
    static func post<S, T>(event: T, limitedToScope scope: S)
}

/// Conformance to the `SubbusScopingProtocol`.
extension Subbus: SubbusScopingProtocol {
    static func addSubscription<S, I, T>(id: I, event: T.Type, limitedToScope scope: S, callback: @escaping (T) -> Void) {
        //Verify data
        guard (scope as? OptionalProtocol) == nil else { log("Subscribe - You may not pass in an optional scope."); return }
        guard let scope = stringFor(id: scope) else { log("Subscribe - String representation of scope is empty."); return }
        
        //Subscribe
        Subbus.addSubscription(id: id, event: ScopedEvent<T>.self) { (event) in
            guard event.scope == scope else { return }
            callback(event.event)
        }
    }
    
    static func post<S, T>(event: T, limitedToScope scope: S) {
        //Verify data
        guard (scope as? OptionalProtocol) == nil else { log("Post - You may not pass in an optional scope."); return }
        guard let scope = stringFor(id: scope) else { log("Post - String representation of scope is empty."); return }
        
        //Post event
        let scopedEvent = ScopedEvent(scope: scope, event: event)
        Subbus.post(event: scopedEvent)
    }
}

/// A special convenience event type that allows subscribers to register to a specified scope.
internal struct ScopedEvent<T> {
    var scope: String
    var event: T
}

/// A simple protocol that conveniently isolates `Optional` protocol conformance
/// without the need for knowing the wrapped type.
internal protocol OptionalProtocol {}

/// Conformance of the `OptionalProtocol`.
extension Optional: OptionalProtocol {}
