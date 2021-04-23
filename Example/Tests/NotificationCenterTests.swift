//
//  NotificationCenterTests.swift
//  Subbus_Tests
//
//  Created by Jangle's MacBook Pro on 3/17/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest



class NotificationCenterTests: XCTestCase {
    class HitCounter {
        @objc func hit() { NotificationCenterTests.hitCount += 1 }
    }
    
    static var hitCount = 0

    override func setUpWithError() throws {
        NotificationCenterTests.hitCount = 0
    }

    override func tearDownWithError() throws {
        NotificationCenterTests.hitCount = 0
    }

    func testAddObserverUsingSelectorWithUnsubscribe() throws {
        let counter = HitCounter()
        let notification = NSNotification.Name(rawValue: "hit")
        NotificationCenter.default.addObserver(counter, selector: #selector(HitCounter.hit), name: notification, object: nil)
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
        
        NotificationCenter.default.removeObserver(counter)
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
    }

    func testAddObserverUsingSelectorWithDeallocation() throws {
        var counter: HitCounter? = HitCounter()
        let notification = NSNotification.Name(rawValue: "hit")
        NotificationCenter.default.addObserver(counter!, selector: #selector(HitCounter.hit), name: notification, object: nil)
        
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
        
        counter = nil
        NotificationCenter.default.post(name: notification, object: nil)
                
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
    }
    
    func testAddObserverUsingBlockWithUnsubscribe() throws {
        let counter = HitCounter()
        let notification = NSNotification.Name(rawValue: "hit")
        let observer = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { (_) in
            counter.hit()
        }
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
                
        NotificationCenter.default.removeObserver(observer)
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
    }
    
    func testAddIntObserver() throws {
        let counter = HitCounter()
        let integer = 1
        let notification = NSNotification.Name(rawValue: "hit")
        NotificationCenter.default.addObserver(integer, selector: #selector(HitCounter.hit), name: notification, object: nil)
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
        
        NotificationCenter.default.removeObserver(counter)
        NotificationCenter.default.post(name: notification, object: nil)
        XCTAssertEqual(NotificationCenterTests.hitCount, 1)
    }
}
