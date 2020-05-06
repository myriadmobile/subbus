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
    
    func testEventUnsubscribe() {
        var count = 0

        //Test
        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self, event: TestClassA.self)
        Subbus.post(event: TestClassA())

        //End condition
        XCTAssertEqual(count, 1)
    }

    func testDualSubscription() {
        var count = 0

        //Test
        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())

        //End condition
        XCTAssertEqual(count, 2)
    }

    func testMutlipleEventsSameID() {
        var count = 0

        //Test
        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.subscribe(id: self, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())

        //End condition
        XCTAssertEqual(count, 1)
    }

    func testMultipleEventsSingleUnsubscribe() {
        var count = 0

        //Test
        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.subscribe(id: self, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self, event: TestClassA.self)
        Subbus.post(event: TestClassB())

        //End condition
        XCTAssertEqual(count, 2)
    }

    func testTestMultiplePost() {
        var count = 0

        //Test
        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA())

        //End condition
        XCTAssertEqual(count, 2)
    }
    
    //Test ID Types
    func testTestOptionalID() {
        var count = 0

        //Test
        let myID: Int? = 1
        Subbus.subscribe(id: myID, event: TestClassA.self) { (event) in
            count += 1 //This should not fire because we do not allow optional IDs
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: myID, event: TestClassA.self)
        Subbus.post(event: TestClassA())

        //End condition
        XCTAssertEqual(count, 0)
    }
    
    func testStringID() {
        var count = 0
        
        let id = "1"
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testIntID() {
        var count = 0
        
        let id = 1
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testNSObjectID() {
        var count = 0
        
        let id = NSObject()
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testStructID() {
        struct FoobarStruct { }
        
        var count = 0
        
        let id = FoobarStruct()
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testClassID() {
        class FoobarClass { }
        
        var count = 0
        
        let id = FoobarClass()
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testScope() { //Scope relies on the stringFor(id:) function - so if scoping works AT ALL, then it should work for all types that the other unit tests run tests against
        var count = 0
        
        let scope = "my_scope"
        Subbus.subscribe(id: self, event: TestClassA.self, limitedToScope: scope) { (event) in
            count += 1
        }
        
        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
            count += 1 //This should NOT fire
        }

        Subbus.post(event: TestClassA(), limitedToScope: scope)
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA(), limitedToScope: scope)
        
        XCTAssertEqual(count, 1)
    }
    
}
