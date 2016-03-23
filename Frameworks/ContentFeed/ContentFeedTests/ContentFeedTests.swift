//
//  ContentFeedTests.swift
//  ContentFeedTests
//
//  Created by Yijia Xu on 3/10/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import XCTest
@testable import ContentFeed

class ContentFeedTests: XCTestCase {
    
    lazy var requestMgr = RequestManager()
    
    override func setUp() {
        super.setUp()
        //http://regdmdv700.athenahealth.com:8080/appsvr/secured/contentfeed/dummy/3
        let config = Config(regproBaseURL: "http://regdmdv700.athenahealth.com:8080", regproEndpoint: "", regproPath: "appsvr/secured/contentfeed/dummy/3", mdpPath: "", servicesBaseURL: "")
        requestMgr.config = config
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetContentFeedItems() {
        let getContentFeedItemsOpExpectation = expectationWithDescription("asyncGetContentFeedItemsCallBack")
        
        requestMgr.getContentFeedItems(3, completion: {
            (success, data, error) in
            XCTAssertTrue(success, "testGetOccupationsOperation failed + \(error?.description)")
            
            getContentFeedItemsOpExpectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "Timed out + \(error?.description)")
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
