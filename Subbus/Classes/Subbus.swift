//
//  Subbus.swift
//
//  Created by Alex Larson on 8/21/18.
//  Edited by Cole Kainz on 12/21/18.
//  Copyright © 2018 Myriad Mobile. All rights reserved.
//

import Foundation

//Classes
fileprivate class ListenerWrapper {
    let identifier: String
    let eventName: String
    let listener: NSObjectProtocol
    
    init(identifier: String, eventName: String, listener: NSObjectProtocol) {
        self.identifier = identifier
        self.eventName = eventName
        self.listener = listener
    }
}

//Implementation
public class Subbus {
    
    private static let shared = Subbus()
    
    private var listeners = [ListenerWrapper]() //TODO: Dictionary key of EventName with array of listeners - would be more performant
    private let eventbusCenter = NotificationCenter()
    
    //Fire
    public static func post<T>(event: T) {
        let eventName = String(reflecting: T.self)
        let name = Notification.Name(eventName)
        
        shared.eventbusCenter.post(name: name, object: event)
    }
    
    //Subscribe
    //TODO: Keep an eye out for a compile-time error to enforce non-optional ids. Optional<Wrapped> is a type and thus the language doesn't seem to support that :(
    public static func subscribe<I, T>(id: I, event: T.Type, callback: @escaping (T) -> Void) {
        //Define strings
        guard let identifier = stringFor(id: id) else { log("Subscribe - String representation of ID is empty."); return }
        let eventName = String(reflecting: event)
        
        //Register listener
        let name = Notification.Name(eventName)
        let listener = shared.eventbusCenter.addObserver(forName: name, object: nil, queue: nil) { (notification) in
            guard let event = notification.object as? T else { return }
            callback(event)
        }
        
        //Cache Listener
        let newListener = ListenerWrapper(identifier: identifier, eventName: eventName, listener: listener)
        shared.listeners.append(newListener)
        
        //Log
        log("Registered listener for identifier \(identifier)")
    }
    
    //Unsubscribe
    public static func unsubscribe<I, T>(id: I, event: T.Type) {
        //Define strings
        guard let identifier = stringFor(id: id) else { log("Unsubscribe - String representation of ID is empty."); return }
        let eventName = String(reflecting: event)
        
        //Retrieve Target Listeners
        let listenerArray = shared.listeners.filter(filter(identifier: identifier, eventName: eventName))
        
        //Unsubscribe Listeners
        for listener in listenerArray {
            shared.eventbusCenter.removeObserver(listener.listener)
        }
        
        //Remove Listeners From Cache
        while let index = shared.listeners.index(where: filter(identifier: identifier, eventName: eventName)) {
            shared.listeners.remove(at: index)
        }
        
        //Log
        log("Unregistered listener for identifier \(identifier)")
    }
    
    public static func unsubscribe<I>(id: I) {
        //Define strings
        guard let identifier = stringFor(id: id) else { log("Unsubscribe - String representation of ID is empty."); return }
        
        //Retrieve Target Listeners
        let listenerArray = shared.listeners.filter(filter(identifier: identifier))
        
        //Unsubscribe Listeners
        for listener in listenerArray {
            shared.eventbusCenter.removeObserver(listener.listener)
        }
        
        //Remove Listeners From Cache
        while let index = shared.listeners.index(where: filter(identifier: identifier)) { //TODO: Maybe do structs; then you can probably do == comparison instead of filter as it stands
            shared.listeners.remove(at: index)
        }
        
        //Log
        log("Unregistered all listeners for identifier \(identifier)")
    }
    
    fileprivate static func filter(identifier: String, eventName: String? = nil) -> (ListenerWrapper) -> Bool {
        return {($0.identifier == identifier) && (eventName != nil ? $0.eventName == eventName : true)}
    }
    
    //Misc
    private static func log(_ message: String) {
        print("Subbus: \(message)")
    }
    
    private static func stringFor<I>(id: I) -> String? {
        //Generics seem to allow optional (because Optional<W> is a type)
        //This we need to check if the type is optional and, if so, verify that the data is not nil.
        //If it is nil - then return immediately.
        if let idO = id as? OptionalProtocol, idO.hasValue() == false { return nil }
        
        //Components for return string
        let unwrappedType = self.unwrappedType(of: id)
        var valString = "" //Value or pointer
        
        //Get the right string type; objects need memory address and primitives just need value.
        if unwrappedType is AnyClass {
            valString = "\(Unmanaged.passUnretained(id as AnyObject).toOpaque())"
        } else {
            valString = "\(id)"
        }
        
        //Ensure that the idString is valid
        guard valString.isEmpty == false else { return nil }
        guard valString != "nil" else { return nil }
        
        let name = "\(unwrappedType)-\(valString)"
        print("NAME: \(name)")
        return name
    }
    
    static func unwrappedType<I>(of object: I) -> Any.Type {
        if let objectOptional = object as? OptionalProtocol {
            return objectOptional.wrappedType()
        } else {
            return I.self
        }
    }
    
}

protocol OptionalProtocol {
    func wrappedType() -> Any.Type
    func hasValue() -> Bool
}

extension Optional: OptionalProtocol {
    func wrappedType() -> Any.Type {
        return Wrapped.self
    }
    
    func hasValue() -> Bool {
        var hasValue = false
        self.map({ $0; hasValue = true })
        return hasValue
    }
}
