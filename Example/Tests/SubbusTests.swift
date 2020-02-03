//
//  SubbusTests.swift
//  SubbusTests
//
//  Created by Cole Kainz on 1/11/19.
//  Copyright © 2019 Myriad Mobile. All rights reserved.
//

import XCTest
@testable import Subbus

class TestClassA{}
class TestClassB{}
class TestClassC{}

class SubbusTests: XCTestCase {
    
//    //Simple flow.
//    func test1() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: self, event: TestClassA.self)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 1)
//    }
//
//    //Simple flow. Broad unsubscribe.
//    func test2() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: self)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 1)
//    }
//
//    //Dual subscription.
//    func test7() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: self)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 2)
//    }
//
//    //Dual subscription. Different events.
//    func test10() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.subscribe(id: self, event: TestClassB.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: self)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 1)
//    }
//
//    //Dual subscription. Single unsubscribe.
//    func test12() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.subscribe(id: self, event: TestClassB.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: self, event: TestClassA.self)
//        Subbus.post(event: TestClassB())
//
//        //End condition
//        XCTAssertEqual(count, 2)
//    }
//
//    //Simple flow. Dual fire.
//    func test13() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: self, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: self, event: TestClassA.self)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 2)
//    }
//
//    //Dual subscription with same IDs.
//    func test14() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: 1, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.subscribe(id: 1, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: 1)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 2)
//    }
//
//    //Dual subscription with different IDs. Unsub both.
//    func test15() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: 1, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.subscribe(id: 2, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: 1)
//        Subbus.unsubscribe(id: 2)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 2)
//    }
//
//    //Dual subscription with different IDs. Unsub one.
//    func test16() {
//        var count = 0
//
//        //Test
//        Subbus.subscribe(id: 1, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.subscribe(id: 2, event: TestClassA.self) { (event) in
//            count += 1
//        }
//
//        Subbus.post(event: TestClassA())
//        Subbus.unsubscribe(id: 1)
//        Subbus.post(event: TestClassA())
//
//        //End condition
//        XCTAssertEqual(count, 3)
//    }
    
    //Non-optional id types
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
    
    //Optional ID types
    func testOptionalStringID() {
        var count = 0
        
        let id: String? = "1"
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testOptionalIntID() {
        var count = 0
        
        let id: Int? = 1
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testOptionalNSObjectID() {
        var count = 0
        
        let id: NSObject? = NSObject()
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testOptionalStructID() {
        struct FoobarStruct { }
        
        var count = 0
        
        let id: FoobarStruct? = FoobarStruct()
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    func testOptionalClassID() {
        class FoobarClass { }
        
        var count = 0
        
        let id: FoobarClass? = FoobarClass()
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 1)
    }
    
    //Nil IDs
    func testNilStringID() {
        var count = 0
        
        let id: String? = nil
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 0)
    }
    
    func testNilIntID() {
        var count = 0
        
        let id: Int? = nil
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 0)
    }
    
    func testNilNSObjectID() {
        var count = 0
        
        let id: NSObject? = nil
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 0)
    }
    
    func testNilStructID() {
        struct FoobarStruct { }
        
        var count = 0
        
        let id: FoobarStruct? = nil
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 0)
    }
    
    func testNilClassID() {
        class FoobarClass { }
        
        var count = 0
        
        let id: FoobarClass? = nil
        Subbus.subscribe(id: id, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: id)
        Subbus.post(event: TestClassA())
        
        XCTAssertEqual(count, 0)
    }
    
}
