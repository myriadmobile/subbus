//
//  SubbusTests.swift
//  SubbusTests
//
//  Created by Cole Kainz on 1/11/19.
//  Copyright © 2019 Myriad Mobile. All rights reserved.
//

import XCTest
@testable import Subbus

class TestClassA {}
class TestClassB {}
class TestClassC {}

class SubbusTests: XCTestCase {
    override func setUpWithError() throws {
        Subbus.logToConsole = true
    }
    
    override func tearDownWithError() throws {
        Subbus.clearHistory()
        Subbus.clearSubscribers()
    }
    
    func testEventSubscribe() {        
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 1)
    }
    
    func testEventUnsubscribe() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self, event: TestClassA.self)
        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 1)
    }
    
    func testObserverUnsubscribe() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }
        
        Subbus.addSubscription(id: self, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.post(event: TestClassB())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())
        Subbus.post(event: TestClassB())

        XCTAssertEqual(count, 2)
    }

    func testRepeatSubscription() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 2)
    }
    
    func testRepeatSubscriptionUnsubscribe() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 2)
    }
    
    func testReplaceSubscription() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self, replace: true) { (event) in
            count += 1
        }

        Subbus.addSubscription(id: self, event: TestClassA.self, replace: true) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 1)
    }

    func testMutlipleEventsSameID() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.addSubscription(id: self, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 1)
    }

    func testMultipleEventsSingleUnsubscribe() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.addSubscription(id: self, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self, event: TestClassA.self)
        Subbus.post(event: TestClassB())

        XCTAssertEqual(count, 2)
    }

    func testMultiplePost() {
        var count = 0

        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 2)
    }
    
    func testUnsubscribeAllObserversOfEvent() {
        var count = 0
        
        let observerA = TestClassA()
        let observerB = TestClassB()

        Subbus.addSubscription(id: observerA, event: TestClassC.self) { (event) in
            count += 1
        }
        
        Subbus.addSubscription(id: observerB, event: TestClassC.self) { (event) in
            count += 1
        }
        
        Subbus.post(event: TestClassC())
        Subbus.unsubscribe(event: TestClassC.self)
        Subbus.post(event: TestClassC())

        XCTAssertEqual(count, 2)
    }
}
