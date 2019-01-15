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
    var testCount = 0
    
    func testExample() {
//
//        //Only events of a given type are called when an scope is not specified
//        resetTest()
//        Subbus.post(event: TestClassA())
//        XCTAssertEqual(testCount, 3) //event 1 and 2
//
//        //Only events of a given type and scope are called when an scope is not specified
//        resetTest()
//        Subbus.post(event: TestClassA(), scope: "scope")
//        XCTAssertEqual(testCount, 2) //event 2
//
//        //All events should be unsubscribed when only the observer is specified in the unsubscribe function
//        resetTest()
//        Subbus.unsubscribe(observer: self)
//        Subbus.post(event: TestClassA())
//        Subbus.post(event: TestClassB())
//        Subbus.post(event: TestClassC())
//        XCTAssertEqual(testCount, 0) //no event
//
//        //All events of a type should be unsubscribed when the observer and type are specified in the unsubscribe function
//        resetTest()
//        Subbus.unsubscribe(observer: self, event: TestClassA.self)
//        Subbus.post(event: TestClassA())
//        Subbus.post(event: TestClassB())
//        Subbus.post(event: TestClassC())
//        XCTAssertEqual(testCount, 12) //event 3 and 4
//
//        //All events with an scope should be unsubscribed when the observer and scope are specified in the unsubscribe function
//        resetTest()
//        Subbus.unsubscribe(observer: self, scope: "scope")
//        Subbus.post(event: TestClassA())
//        Subbus.post(event: TestClassB())
//        Subbus.post(event: TestClassC())
//        XCTAssertEqual(testCount, 5) //event 1 and 3
//
//        //All events with an scope and type should be unsubscribed when the observer, type, and scope are specified in the unsubscribe function
//        resetTest()
//        Subbus.unsubscribe(observer: self, event: TestClassA.self, scope: "scope")
//        Subbus.post(event: TestClassA())
//        Subbus.post(event: TestClassB())
//        Subbus.post(event: TestClassC())
//        XCTAssertEqual(testCount, 13) //event 1, 3, and 4
    }

    //Note: A subscription of a given event and scope (including a non-specified scope) cannot be subscribed twice.
    //If a subscription is made twice, the new one overwrites the old.
    func resetTest() {
        //Ensure each subscribe function is only run once and each callback adds a unique power of two to testCount.
        //This ensures the resulting sum only has one possible combination of events that can lead to it.
        // I.E. calling event 2 and event 4 results in a testCount of 2 + 8 = 10. There is no other combination of events that can get to 10.
        
        testCount = 0
        Subbus.subscribe(observer: self, event: TestClassA.self) { (_) in self.testCount += 1 } //1
        Subbus.subscribe(observer: self, event: TestClassA.self, scope: "scope" ) { (_) in self.testCount += 2 } //2
        Subbus.subscribe(observer: self, event: TestClassB.self) { (_) in self.testCount += 4 } //3
        Subbus.subscribe(observer: self, event: TestClassC.self, scope: "scope" ) { (_) in self.testCount += 8 } //4
    }
}
