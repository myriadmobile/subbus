//
//  SubbusTests.Types.swift
//  Subbus_Tests
//
//  Created by Jangle's MacBook Pro on 3/15/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import Subbus

extension SubbusTests {    
    func testStringID() {
        var count = 0
        
        let id = "1"
        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
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
        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
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
        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
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
        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
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
        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testTupleID() {
        let id = ("val1", TestClassA())

        var count = 0

        Subbus.addSubscription(id: id, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassB())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassB())

        XCTAssertEqual(count, 1)
    }
    
    func testEnumID() {
        enum idEnum {
            case case1, case2
        }
        
        let id = idEnum.case1
        
        var count = 0
        
        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testCollectionId() {
        let id: [Any] = ["val1", TestClassA()]
        
        var count = 0

        Subbus.addSubscription(id: id, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassB())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassB())

        XCTAssertEqual(count, 1)
    }
    
    func testDictionaryId() {
        let id: [AnyHashable: Any] = ["val1": TestClassA()]

        var count = 0

        Subbus.addSubscription(id: id, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassB())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassB())

        XCTAssertEqual(count, 1)
    }
    
    func testSetId() {
        let id = Set(arrayLiteral: ["val1", NSObject()] as [AnyHashable])

        var count = 0

        Subbus.addSubscription(id: id, event: TestClassB.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassB())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassB())

        XCTAssertEqual(count, 1)
    }
}
