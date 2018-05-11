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
    
    func testExpressionEvaluatorNegative() throws {
        let evaluator = TokenizerEvaluator()
        
        XCTAssertThrowsError(try evaluator.evaluateExpression(expression: "1+4*ab+3", paramDictionary: "[abc:5]")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.EvaluationError, TokenizerEvaluator.EvaluationError.variableNotDefined)
        }
        XCTAssertThrowsError(try evaluator.evaluateExpression(expression: "1+4*ab+3/zx", paramDictionary: "[ab:5, zx:0]")) { error in
            XCTAssertEqual(error as! TokenizerEvaluator.EvaluationError, TokenizerEvaluator.EvaluationError.tryingToDivideByZero)
        }

    }
    
    func testExpressionEvaluatorPositive() throws {
        let evaluator = TokenizerEvaluator()
        let results = try evaluator.evaluateExpression(expression: "1+4*abc+3", paramDictionary: "[abc:5]")
        let expected = ("Constant(1), Operator(+), Constant(4), Operator(*), Identifier(abc), Operator(+), Constant(3), ", "24")
        
        print(results.1)
        let eql = results == expected
        XCTAssert(eql)
        
        let results2 = try evaluator.evaluateExpression(expression: "", paramDictionary: "[abc:5]")
        XCTAssertEqual(results2.0, "")
        XCTAssertEqual(results2.1, "0")
        
        let results3 = try evaluator.evaluateExpression(expression: "ab+cd", paramDictionary: "[ab:5, cd: 2]")
        XCTAssertEqual(results3.1, "7")
        
        let results4 = try evaluator.evaluateExpression(expression: "1/3*3", paramDictionary: "[ab:5, cd: 2]")
        XCTAssertEqual(results4.1, "1")

        let results5 = try evaluator.evaluateExpression(expression: "7-77", paramDictionary: "[ab:5, cd: 2]")
        XCTAssertEqual(results5.1, "-70")

        
    }
    
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
