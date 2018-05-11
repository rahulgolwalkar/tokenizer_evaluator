//
//  TokenizerEvaluatorTests.swift
//  TokenizerEvaluatorTests
//
//  Created by rahulg on 10/05/18.
//  Copyright © 2018 rahulg. All rights reserved.
//

import XCTest
@testable import TokenizerEvaluator

class TokenizerEvaluatorTests: XCTestCase {
    
    // test rounded cases
    // - > 0
    // -  < 1
    // - input spaces and without spaces should evaluate same
    // - invalid characters should throw errors
    // -- if you implement brackets then check if it ever becomes negative
    // - bodmas stack should evaluate differently
    // - if a variable has numbers in between throw error .
    // - each funciton test
    // - test case for each error condition

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // MARK : Test expressionParser
    
    func testExpressionParserNegative() throws {
        let evaluator = TokenizerEvaluator()
        
        XCTAssertThrowsError(try evaluator.expressionParser(inputToken: "4+1++")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InvalidChar, TokenizerEvaluator.InvalidChar.consecutiveOperator)
        }
        XCTAssertThrowsError(try evaluator.expressionParser(inputToken: "1+abc+")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InvalidChar, TokenizerEvaluator.InvalidChar.endCharIsOperator)
        }
        XCTAssertThrowsError(try evaluator.expressionParser(inputToken: "+1+abc")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InvalidChar, TokenizerEvaluator.InvalidChar.endCharIsOperator)
        }
        XCTAssertThrowsError(try evaluator.expressionParser(inputToken: "1+ab&c")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InvalidChar, TokenizerEvaluator.InvalidChar.invalidCharacter)
        }
        XCTAssertThrowsError(try evaluator.expressionParser(inputToken: "1+ab4c+7")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InvalidChar, TokenizerEvaluator.InvalidChar.invalidIdentifierWithNumber)
        }
        XCTAssertThrowsError(try evaluator.expressionParser(inputToken: "1+34u+7")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InvalidChar, TokenizerEvaluator.InvalidChar.invalidNumberWithIdentifier)
        }




    }
    
    func testExpressionParserPositive() throws {
        let evaluator = TokenizerEvaluator()
        
        
        let eval = try evaluator.expressionParser(inputToken: "1+400* abc+ 3/m")
        let expected = [(TokenizerEvaluator.TokenType.constant, "1"),(TokenizerEvaluator.TokenType.operatorType, "+"), (TokenizerEvaluator.TokenType.constant, "400"), (TokenizerEvaluator.TokenType.operatorType, "*"),  (TokenizerEvaluator.TokenType.identifier, "abc"), (TokenizerEvaluator.TokenType.operatorType, "+"), (TokenizerEvaluator.TokenType.constant, "3"), (TokenizerEvaluator.TokenType.operatorType, "/"), (TokenizerEvaluator.TokenType.identifier, "m")]
        var equal = true
        for i in 0 ..< eval.count {
            if (eval[i] != expected[i]) {
                equal = false
            }
        }
        XCTAssert(equal)
    }
    
    
    // MARK : Test parseInputDictionary
    
    func testParseInputDictionaryNegative() throws {
        let evaluator = TokenizerEvaluator()
        XCTAssertThrowsError(try evaluator.parseInputDictionary(inputString: "[ abc 4 , pqr: 7]")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InputDicError, TokenizerEvaluator.InputDicError.invalidInputFormat)
        }
        XCTAssertThrowsError(try evaluator.parseInputDictionary(inputString: "[ abc : 4 , abc: 7]")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InputDicError, TokenizerEvaluator.InputDicError.duplicateParameters)
        }
        XCTAssertThrowsError(try evaluator.parseInputDictionary(inputString: "[ abc : 4f , abc: 7]")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.InputDicError, TokenizerEvaluator.InputDicError.notAnInteger)
        }

    }
    
    func testParseInputDictionaryPositive() throws {
        let evaluator = TokenizerEvaluator()
        let dic = try evaluator.parseInputDictionary(inputString: "[ abc : 4 , pqr: 7]")
        XCTAssertEqual(dic, ["abc": "4", "pqr": "7"])
        XCTAssertNotEqual(dic, ["abc": "5"])
        XCTAssertNotEqual(dic, ["abc": "4"])
    }
    
    // MARK : Test expressionEvaluator
    
    // MARK : test Stack implementation
    
    func testEmptyStack() {
        var stack = Stack<Int>()
        XCTAssertTrue(stack.isEmpty)
        XCTAssertEqual(stack.count, 0)
        XCTAssertEqual(stack.top, nil)
        XCTAssertNil(stack.pop())
    }
    
    func testOneElementStack() {
        var stack = Stack<Int>()
        
        stack.push(123)
        XCTAssertFalse(stack.isEmpty)
        XCTAssertEqual(stack.count, 1)
        XCTAssertEqual(stack.top, 123)
        
        let result = stack.pop()
        XCTAssertEqual(result, 123)
        XCTAssertTrue(stack.isEmpty)
        XCTAssertEqual(stack.count, 0)
        XCTAssertEqual(stack.top, nil)
        XCTAssertNil(stack.pop())
    }
    
    func testTwoElementsStack() {
        var stack = Stack<Int>()
        
        stack.push(123)
        stack.push(456)
        XCTAssertFalse(stack.isEmpty)
        XCTAssertEqual(stack.count, 2)
        XCTAssertEqual(stack.top, 456)
        
        let result1 = stack.pop()
        XCTAssertEqual(result1, 456)
        XCTAssertFalse(stack.isEmpty)
        XCTAssertEqual(stack.count, 1)
        XCTAssertEqual(stack.top, 123)
        
        let result2 = stack.pop()
        XCTAssertEqual(result2, 123)
        XCTAssertTrue(stack.isEmpty)
        XCTAssertEqual(stack.count, 0)
        XCTAssertEqual(stack.top, nil)
        XCTAssertNil(stack.pop())
    }
    
    func testMakeEmptyStack() {
        var stack = Stack<Int>()
        
        stack.push(123)
        stack.push(456)
        XCTAssertNotNil(stack.pop())
        XCTAssertNotNil(stack.pop())
        XCTAssertNil(stack.pop())
        
        stack.push(789)
        XCTAssertEqual(stack.count, 1)
        XCTAssertEqual(stack.top, 789)
        
        let result = stack.pop()
        XCTAssertEqual(result, 789)
        XCTAssertTrue(stack.isEmpty)
        XCTAssertEqual(stack.count, 0)
        XCTAssertEqual(stack.top, nil)
        XCTAssertNil(stack.pop())
    }


    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
