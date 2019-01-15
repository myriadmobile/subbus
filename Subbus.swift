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
    let observer: String
    let eventName: String
    let eventScope: String?
    let listener: NSObjectProtocol
    
    init(observer: String, eventName: String, eventScope: String?, listener: NSObjectProtocol) {
        self.observer = observer
        self.eventName = eventName
        self.eventScope = eventScope
        self.listener = listener
    }
}

fileprivate class EventWrapper {
    let event: Any
    let scope: String?
    
    init(event: Any, scope: String?) {
        self.event = event
        self.scope = scope
    }
}

//Implementation
public class Subbus {
    
    private static let shared = Subbus()
    
    private var listeners = [ListenerWrapper]()
    private let eventbusCenter = NotificationCenter()
    
    //Fire
    //Event is Any? because Any is implicitly optional, we MUST do a guard let to trim Optional() from the string representing the type to return a non-optional object
    public static func post(event: Any?, scope: String? = nil) {
        
        guard let event = event else {
            print("Subbus: No object found. Cannot fire.")
            return
        }
        
        let eventName = String(reflecting: event)
        let wrappedEvent = EventWrapper(event: event, scope: scope)
        
        //Post Notification
        let name = Notification.Name(eventName)
        shared.eventbusCenter.post(name: name, object: wrappedEvent)
    }
    
    //Subscribe
    public static func subscribe<T>(observer: NSObject, event: T.Type, scope: String? = nil, callback: @escaping (T) -> Void) {
        weak var weakObserver: NSObject? = observer //Make a weak copy so that we DON'T cause a retain cycle with the observer.
        
        //Define Strings
        let observerName = "\(observer)"
        let eventName = String(reflecting: event)
        
        //Check For Duplicates - Last In First Out [new subscriptions replace old]
        //Make sure nil scopes don't unsubscribe all events
        if shared.listeners.first(where: filterExactScope(observerName: observerName, eventName: eventName, scope: scope)) != nil {
            unsubscribe(observer: observer, event: event, scope: scope) //Unsusbscribe old one to prevent duplicate events
        }
        
        //Add Observer
        let name = Notification.Name(eventName)
        let listener = shared.eventbusCenter.addObserver(forName: name, object: nil, queue: nil) { (notification) in
            guard let _ = weakObserver else { return } //Check to see if observer still exists
            let wrappedEvent = notification.object as! EventWrapper
            if wrappedEvent.scope == nil || wrappedEvent.scope == scope {
                callback(wrappedEvent.event as! T)
            }
        }
        
        //Cache Listener
        let newListener = ListenerWrapper(observer: observerName, eventName: eventName, eventScope: scope, listener: listener)
        shared.listeners.append(newListener)
    }
    
    //Unsubscribe
    public static func unsubscribe<T>(observer: NSObject, event: T.Type, scope: String? = nil) {
        //Define Strings
        let observerName = "\(observer)"
        let eventName = String(reflecting: event)
                
        //Retrieve Target Listeners
        let listenerArray = shared.listeners.filter(filter(observerName: observerName, eventName: eventName, scope: scope))
        
        //Unsubscribe Listeners
        for listener in listenerArray {
            shared.eventbusCenter.removeObserver(listener.listener)
        }
        
        //Remove Listeners From Cache
        while let index = shared.listeners.index(where: filter(observerName: observerName, eventName: eventName, scope: scope)) {
            shared.listeners.remove(at: index)
        }
    }
    
    public static func unsubscribe(observer: NSObject, scope: String? = nil) {
        //Define Strings
        let observerName = "\(observer)"
        
        //Retrieve Target Listeners
        let listenerArray = shared.listeners.filter(filter(observerName: observerName, scope: scope))
        
        //Unsubscribe Listeners
        for listener in listenerArray {
            shared.eventbusCenter.removeObserver(listener.listener)
        }
        
        //Remove Listeners From Cache
        while let index = shared.listeners.index(where: filter(observerName: observerName, scope: scope)) {
            shared.listeners.remove(at: index)
        }
    }
    
    fileprivate static func filter(observerName: String, eventName: String? = nil, scope: String? = nil) -> (ListenerWrapper) -> Bool {
        return {($0.observer == observerName) &&
                (eventName != nil ? $0.eventName == eventName : true) &&
                (scope != nil ? $0.eventScope == scope : true)}
    }
    
    fileprivate static func filterExactScope(observerName: String, eventName: String? = nil, scope: String? = nil) -> (ListenerWrapper) -> Bool {
        return {($0.observer == observerName) &&
                (eventName != nil ? $0.eventName == eventName : true) &&
                ($0.eventScope == scope)}
    }
}
