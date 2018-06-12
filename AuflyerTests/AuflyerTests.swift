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
    
    func testGetMemberListData() {
        
        let vc = ContactViewController()
        
        let presenter = ContactViewPresenter(view: vc as ContactView)
        
        let expectation = self.expectation(description: "等待异步调用过程结束")
        
        presenter.getData(){
            
            XCTAssert(presenter.data.count>0,"no data received from server")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) {
            error in
            if let error = error {
                XCTFail("超时错误 \(error.localizedDescription)")
            }
        }
    }
    
    func testDeleteData() -> Void {
        
        let expectation = self.expectation(description: "等待异步调用过程结束")

        let presenter = ContactViewPresenter(view: ContactViewController())
        
        presenter.data = [Client(),Client(),Client()]
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        presenter.deleteItemInServer(indexPath: indexPath)
        
        expectation.fulfill()

        XCTAssert(presenter.data.count != 2,"no data is delete")
        
        self.waitForExpectations(timeout: 10) {
            error in
            if let error = error {
                XCTFail("超时错误 \(error.localizedDescription)")
            }
        }
    }
    
    func testReduceDuiplicate() -> Void {
        let vc = ContactViewController()
        
        let presenter = ContactViewPresenter(view: vc)
        
        let array : NSMutableArray = NSMutableArray()
        
        for _ in 0...5
        {
            let client : Client = Client()
            client._fullname = "Peter"
            client._address = ["Address"]
            client._mobile = ["Mobile Phone Number"]
            client._chineseIDNumber = ["ID number"]
            array.add(client)
        }
        
        vc.searchResult = array
        
        presenter.removeDupilicatedContact()
        
        XCTAssert(vc.searchResult.count == 1,"duiplicate client is deleted")
        
    }
}
