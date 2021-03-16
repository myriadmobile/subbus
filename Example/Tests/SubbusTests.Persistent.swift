//
//  SubbusTests.Persistent.swift
//  Subbus_Tests
//
//  Created by Jangle's MacBook Pro on 5/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import Subbus

class PersistentTestClassA: PersistentEvent {
    var exampleVar: String?
    
    init() {
        super.init(persistenceRule: .clearImmediately)
    }
}

extension SubbusTests {
    func testPostingWithoutSubscription() {
        Subbus.post(event: PersistentTestClassA())
        
        XCTAssert(Subbus.unhandledEvents.count == 1, "Subbus is not persisting unhandled events")
    }
    
    func testSubscribingBeforePosting() throws {
        var received = false
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            received = true
            return .handledSuccessfully
        }
        
        let event = PersistentTestClassA()
        Subbus.post(event: event)
        
        XCTAssert(received, "Subbus event was not received when subscribing before posting")
        XCTAssert(Subbus.unhandledEvents.count == 0, "Subbus event was not handled when subscribing before posting")
    }
    
    func testPostingBeforeSubscribing() throws {
        let event = PersistentTestClassA()
        Subbus.post(event: event)
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            return .handledSuccessfully
        }
        
        XCTAssert(Subbus.unhandledEvents.count == 0, "Subbus event was not handled when posting before subscribing")
    }
    
    func testSubscriberNotHandlingEvent() throws {
        let event = PersistentTestClassA()
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            return .failed
        }
        
        Subbus.post(event: event)
        
        XCTAssert(Subbus.unhandledEvents.count == 1, "Subbus event was lost even though no subscriber handled it")
    }
    
    func testVariablesBeingPersisted() throws {
        let event = PersistentTestClassA()
        event.exampleVar = "testVariablesBeingPersisted"
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            XCTAssert(event.exampleVar == "testVariablesBeingPersisted", "PersistentTestClassA's variable was not persisted")
            return .handledSuccessfully
        }
        
        Subbus.post(event: event)
    }
    
    func testFirstSubscriberReceivesEvent() throws {
        let event = PersistentTestClassA()

        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            return .handledSuccessfully
        }
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            XCTFail("Second subscriber received event, but shouldn't have")
            return .failed
        }
        
        Subbus.post(event: event)
    }
    
    func testMultiplePostedEventsReceivedWhenSubscribing() throws {
        var events = [PersistentTestClassA]()
        
        for i in 0 ..< 3 {
            let event = PersistentTestClassA()
            event.exampleVar = "\(i)"
            events.append(event)
            Subbus.post(event: event)
        }
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            events = events.filter({ $0.exampleVar != event.exampleVar })
            return .handledSuccessfully
        }
        
        XCTAssert(events.count == 0, "Multiple posted events not received when subscribing")
    }
    
    func testEventsReceivedChronologically() throws {
        for i in 0 ..< 3 {
            let event = PersistentTestClassA()
            event.exampleVar = "\(i)"
            Subbus.post(event: event)
        }
        
        var receivedCount = 0
        
        Subbus.addSubscription(id: self, event: PersistentTestClassA.self) { (event) -> PersistentEvent.HandlerResult in
            XCTAssert(event.exampleVar == "\(receivedCount)", "Events were not received chronologically after subscribing")
            receivedCount += 1
            return .handledSuccessfully
        }
    }
}
