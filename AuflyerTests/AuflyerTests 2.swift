//
//  AuflyerTests.swift
//  AuflyerTests
//
//  Created by Yingyong on 2018/5/25.
//

import XCTest
@testable import Auflyer

class AuflyerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetData() {
        let vc = ContactViewPresenter()
        presenter.getData()
        XCTAssert(presenter.data.count>0,"count is no 0")
    }
    
}
