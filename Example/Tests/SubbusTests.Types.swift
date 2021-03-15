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
  
    // TODO: Struct support
//    func testStructID() {
//        struct FoobarStruct { }
//
//        var count = 0
//
//        let id = FoobarStruct()
//        Subbus.addSubscription(id: id, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: id)
//        Subbus.post(event: TestClassA())
//
//        XCTAssertEqual(count, 1)
//    }
    
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
}
