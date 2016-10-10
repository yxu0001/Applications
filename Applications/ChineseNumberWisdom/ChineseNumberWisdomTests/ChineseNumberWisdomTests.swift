//
//  ChineseNumberWisdomTests.swift
//  ChineseNumberWisdomTests
//
//  Created by Yijia Xu on 10/5/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import XCTest
@testable import ChineseNumberWisdom

class ChineseNumberWisdomTests: XCTestCase {
    
    var engine: NumberWisdomEngine!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        engine = NumberWisdomEngine()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test901() {
        let (word, result) = engine.findLuck(901)!
        XCTAssertEqual(word, "先历困苦，后得幸福，霜雪梅花，春来怒放。")
        XCTAssertEqual(result, "吉")
    }
    
    func test3836() {
        let (word, result) = engine.findLuck(3836)!
        XCTAssertEqual(word, "此数大凶，破产之象，宜速改名，以避厄运。")
        XCTAssertEqual(result, "凶")
    }

    func test1008() {
        let (word, result) = engine.findLuck(1008)!
        XCTAssertEqual(word, "华美丰实，鹤立鸡群，名利俱全，繁荣富贵。")
        XCTAssertEqual(result, "吉")
    }

    func test4974() {
        let (word, result) = engine.findLuck(4974)!
        XCTAssertEqual(word, "忍得苦难，必有后福。是成是败，惟靠毅力。")
        XCTAssertEqual(result, "凶")

        print(word)
        print(result)
    }
    
}
