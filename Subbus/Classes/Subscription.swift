//
//  Subscription.swift
//  Subbus
//
//  Created by Jangle's MacBook Pro on 3/16/21.
//

import Foundation

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
