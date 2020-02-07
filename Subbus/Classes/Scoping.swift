//
//  Scoping.swift
//  Pods-Subbus_Example
//
//  Created by Alex Larson on 2/6/20.
//

//NOTE: Scoping is secondary behavior. It should be built on top of the core Subbus functionality.
//Scope is a way of saying "Only give MYEVENT to listeners that want MYEVENT and match a specific scope"

//There is no easy way to unsubscribe from a particular scope by using ONLY the scope.
//I.e. there is no 'unsubscribe(id:event:scope:)'
//If you want to unsubscribe from with a particular scope - use a unique ID (for example - reuse the scope!).
//Ex:
//let scope = "abc"
//subscribe(id: scope, MyEvent.self, limitedToScope: scope)
//unsubscribe(id: scope, MyEvent.self)

struct ScopedEvent<T> { var scope: String, event: T }

public extension Subbus {
    
    public static func post<S, T>(event: T, limitedToScope scope: S) {
        //Verify data
        guard (scope as? OptionalProtocol) == nil else { log("Post - You may not pass in an optional scope."); return }
        
        //Define strings
        guard let scope = stringFor(id: scope) else { log("Post - String representation of scope is empty."); return }
        
        //Post event
        let scopedEvent = ScopedEvent(scope: scope, event: event)
        Subbus.post(event: scopedEvent)
    }
    
    public static func subscribe<S, I, T>(id: I, event: T.Type, limitedToScope scope: S, callback: @escaping (T) -> Void) {
        //Verify data
        guard (scope as? OptionalProtocol) == nil else { log("Subscribe - You may not pass in an optional scope."); return }
        
        //Define strings
        guard let scope = stringFor(id: scope) else { log("Subscribe - String representation of scope is empty."); return }
        
        //Subscribe
        Subbus.subscribe(id: id, event: ScopedEvent<T>.self) { (event) in
            guard event.scope == scope else { return }
            callback(event.event)
        }
    }
    
}
