//
//  SubbusTests.Scoping.swift
//  Subbus_Tests
//
//  Created by Jangle's MacBook Pro on 3/15/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import Subbus

extension SubbusTests {
    func testScope() { //Scope relies on the stringFor(id:) function - so if scoping works AT ALL, then it should work for all types that the other unit tests run tests against
        var count = 0
        
        let scope = "my_scope"
        Subbus.addSubscription(id: self, event: TestClassA.self, limitedToScope: scope) { (event) in
            count += 1
        }
        
        Subbus.addSubscription(id: self, event: TestClassA.self) { (event) in
            count += 1 //This should NOT fire
        }

        Subbus.post(event: TestClassA(), limitedToScope: scope)
        Subbus.unsubscribe(id: self)
        Subbus.post(event: TestClassA(), limitedToScope: scope)
        
        XCTAssertEqual(count, 1)
    }
}
