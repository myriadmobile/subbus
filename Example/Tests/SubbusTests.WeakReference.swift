//
//  SubbusTests.WeakReference.swift
//  Subbus_Tests
//
//  Created by Jangle's MacBook Pro on 3/15/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import Subbus

extension SubbusTests {
    func testOptionalID() {
        var count = 0

        let myID: Int? = 1
        Subbus.addSubscription(id: myID, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())
        Subbus.unsubscribe(id: myID, event: TestClassA.self)
        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 1)
    }
    
    func testNilId() {
        var count = 0

        let myID: Int? = nil
        Subbus.addSubscription(id: myID, event: TestClassA.self) { (event) in
            count += 1
        }

        Subbus.post(event: TestClassA())

        XCTAssertEqual(count, 0)
    }
    
    func testWeakUnsubscribe() {
        var testID: TestClassA? = TestClassA()
        var count = 0
        let expectation = self.expectation(description: "testWeakUnsubscribe")
        
        Subbus.addSubscription(id: testID, event: TestClassB.self) { (event) in
            count += 1
        }
        
        Subbus.post(event: TestClassB())
                
        // Discard the subscriber
        testID = nil
        
        // Release this thread so ARC can dispose of it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Since our subscriber was a class, Subbus should have cleaned it up
            Subbus.post(event: TestClassB())
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(count, 1)
    }
    
    func testNonClassTypeRetention() {
        var testID: Int? = 1
        var count = 0
        let expectation = self.expectation(description: "testNonClassTypeRetention")
        
        Subbus.addSubscription(id: testID, event: TestClassA.self) { (event) in
            count += 1
        }
        
        Subbus.post(event: TestClassA())
                
        // Discard the subscriber
        testID = nil
        
        // Release this thread so ARC can dispose of it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Since our subscriber was a non-class, Subbus should have retained the subscription
            Subbus.post(event: TestClassA())
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(count, 2)
    }
}

