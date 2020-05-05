//
//  Subbus.swift
//
//  Created by Alex Larson on 8/21/18.
//  Edited by Cole Kainz on 12/21/18.
//  Copyright © 2018 Myriad Mobile. All rights reserved.
//

import Foundation

//An easy way to check if something is optional without knowing the Wrapped type
protocol OptionalProtocol {}
extension Optional: OptionalProtocol {}

protocol SubbusProtocol {
    static func subscribe<I, T>(id: I, event: T.Type, callback: @escaping (T) -> Void)
    static func unsubscribe<I, T>(id: I, event: T.Type)
    static func unsubscribe<I>(id: I)
    static var logToConsole: Bool { get set }
}

//Implementation
public class Subbus: SubbusProtocol {
    
    //State
    static var logToConsole: Bool = false
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
        //Verify data
        guard (id as? OptionalProtocol) == nil else { log("Subscribe - You may not pass in an optional ID."); return }
        
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
        //Verify data
        guard (id as? OptionalProtocol) == nil else { log("Subscribe - You may not pass in an optional ID."); return }
        
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
        while let index = shared.listeners.firstIndex(where: filter(identifier: identifier, eventName: eventName)) {
            shared.listeners.remove(at: index)
        }
        
        //Log
        log("Unregistered listener for identifier \(identifier)")
    }
    
    public static func unsubscribe<I>(id: I) {
        //Verify data
        guard (id as? OptionalProtocol) == nil else { log("Subscribe - You may not pass in an optional ID."); return }
        
        //Define strings
        guard let identifier = stringFor(id: id) else { log("Unsubscribe - String representation of ID is empty."); return }
        
        //Retrieve Target Listeners
        let listenerArray = shared.listeners.filter(filter(identifier: identifier))
        
        //Unsubscribe Listeners
        for listener in listenerArray {
            shared.eventbusCenter.removeObserver(listener.listener)
        }
        
        //Remove Listeners From Cache
        while let index = shared.listeners.firstIndex(where: filter(identifier: identifier)) { //TODO: Maybe do structs; then you can probably do == comparison instead of filter as it stands
            shared.listeners.remove(at: index)
        }
        
        //Log
        log("Unregistered all listeners for identifier \(identifier)")
    }
    
    fileprivate static func filter(identifier: String, eventName: String? = nil) -> (ListenerWrapper) -> Bool {
        return {($0.identifier == identifier) && (eventName != nil ? $0.eventName == eventName : true)}
    }
    
    //Misc
    static func log(_ message: String) {
        guard logToConsole == true else { return }
        print("Subbus: \(message)")
    }
    
    static func stringFor<I>(id: I) -> String? {
        var valString = "" //Value or pointer
        
        //Get the right string type; objects need memory address and primitives just need value.
        if I.self is AnyClass {
            valString = "\(Unmanaged.passUnretained(id as AnyObject).toOpaque())"
        } else {
            valString = "\(id)"
        }
        
        //Ensure that the idString is valid
        guard valString.isEmpty == false else { return nil }
        guard valString != "nil" else { return nil }
        
        let name = "\(I.self)-\(valString)"
        return name
    }
}

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
