//
//  TokenizerEvaluator.swift
//  TokenizerEvaluator
//
//  Created by rahulg on 10/05/18.
//  Copyright © 2018 rahulg. All rights reserved.
//

import Foundation

struct TokenizerEvaluator {
    
    
    enum TokenType: String, Equatable {
        case identifier = "Identifier"
        case operatorType = "Operator"
        case constant = "Constant"
    }
    
    func parseInputDictionary(inputString: String) throws -> [String:String] {
        var valueDictionary = [String:String]()
        let inputString = inputString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        if inputString.count == 0 {
            return valueDictionary
        }
        
        let inputArray = inputString.components(separatedBy: ",")
        
        for item in inputArray {
            let itemArray = item.components(separatedBy: ":")
            if (itemArray.count != 2) {
                throw InputDicError.invalidInputFormat
            }
            if (Int(itemArray[1]) == nil) {
                throw InputDicError.notAnInteger
            }
            
            if (valueDictionary[itemArray[0]] != nil) {
                throw InputDicError.duplicateParameters
            }
            
            valueDictionary[itemArray[0]] = itemArray[1]
        }
        return valueDictionary
    }
    
    func expressionParser(inputToken: String) throws -> [(TokenType, String)]  {
        
        var tokenArray: [(TokenType, String)] = []
        
        let tokens = inputToken.replacingOccurrences(of: " ", with: "")
        
        
        var i = 0
        while (i<tokens.count) {
            if ( !isValidInputChar(char: tokens[i])) {
                throw InvalidChar.invalidCharacter
            }
            
            if (isValidNumberChar(char: tokens[i])) {
                var tempString = ""
                while (i < tokens.count && isValidNumberChar(char: tokens[i])) {
                    tempString.append(tokens[i])
                    if (i < (tokens.count - 1) ) {
                        i += 1
                    } else if (i == tokens.count - 1) {
                        break
                    }
                    if (!isValidInputChar(char: tokens[i])) {
                        throw InvalidChar.invalidCharacter
                    }
                }
                tokenArray.append((TokenType.constant,tempString))
                if (isValidIdentifierCharacter(char: tokens[i])) {
                    throw InvalidChar.invalidNumberWithIdentifier
                }
            }
            if (isValidIdentifierCharacter(char: tokens[i])) {
                var tempString = ""
                while (i < tokens.count && isValidIdentifierCharacter(char: tokens[i])) {
                    tempString.append(tokens[i])
                    if (i < (tokens.count - 1)) {
                        i += 1
                    } else if (i == tokens.count - 1) {
                        break
                    }
                    if (!isValidInputChar(char: tokens[i])) {
                        throw InvalidChar.invalidCharacter
                    }

                }
                tokenArray.append((TokenType.identifier, tempString))
                if (isValidNumberChar(char: tokens[i])) {
                    throw InvalidChar.invalidIdentifierWithNumber
                }
            }
            if (isOperator(char: tokens[i])) {
                if (i == (tokens.count - 1)) || (i == 0)  {
                    throw InvalidChar.endCharIsOperator
                }
                if ((i+1) < tokens.count && isOperator(char: tokens[i+1])) {
                    throw InvalidChar.consecutiveOperator
                }
                tokenArray.append((TokenType.operatorType, String(tokens[i])))
            }
            i += 1
        }
        return tokenArray
    }
    
    func evaluateExpression(expression: String, paramDictionary: String) throws -> (String, String) {
        
        let expression = expression.replacingOccurrences(of: " ", with: "")
        
        if (expression.count < 1) {
            return ("", "0")
        }
        
        let paramDictionary = try parseInputDictionary(inputString: paramDictionary)
        var tokenArray = try expressionParser(inputToken: expression)
        
        var outPutSting = ""
        for i in 0..<tokenArray.count {
            let item = tokenArray[i]
            outPutSting.append("\(item.0.rawValue)(\(item.1)), ")
            if item.0 == TokenType.identifier {
                guard let tempVal = paramDictionary[item.1] else {
                    throw EvaluationError.variableNotDefined
                }
                tokenArray[i] = (TokenType.constant, tempVal)
            }
        }
        
        var operatorStack = Stack(array: [String]())
        var valueStack = Stack(array: [String]())
        
        var i = 0
        while (i < tokenArray.count) {
            let item = tokenArray[i]
            if (item.0 == TokenType.constant) {
                valueStack.push(item.1)
            } else  if (item.0 == TokenType.operatorType) {
                while (!operatorStack.isEmpty && hasPrecedence(op1: item.1, op2: operatorStack.top!)) {
                    try valueStack.push(applyOp(op: operatorStack.pop()!, b: valueStack.pop()!, a: valueStack.pop()!))
                }
                operatorStack.push(item.1)
            }
            i += 1
        }
        
        while (!operatorStack.isEmpty) {
            try valueStack.push(applyOp(op: operatorStack.pop()!, b: valueStack.pop()!, a: valueStack.pop()!))
        }
        
        
        let result = (valueStack.pop()! as NSString).floatValue
        let rounded = lround(Double(result))
        
        return (outPutSting, "\(rounded)")
    }

    func isValidInputChar(char: Character) -> Bool {
        if (isValidNumberChar(char: char)) {
            return true
        }
        if (isOperator(char: char)) {
            return true
        }
        if (isValidIdentifierCharacter(char: char)) {
            return true
        }
        return false
    }
    
    func isValidNumberChar(char: Character) -> Bool {
        if (char >= "0" && char <= "9") {
            return true
        }
        return false
    }
    
    func isOperator(char: Character) -> Bool {
        if ("+-*/".contains(char)) {
            return true
        }
        return false
    }
    
    func isValidIdentifierCharacter(char: Character) -> Bool {
        if (char >= "a" && char <= "z") || (char >= "A" && char <= "Z") {
            return true
        }
        return false
    }
    
    func isValidIdentifier(identifier: String) -> Bool {
        for c in identifier {
            if !isValidIdentifierCharacter(char: c) {
                return false
            }
        }
        return true
    }
    
    enum InvalidChar: Error {
        case invalidCharacter
        case invalidIdentifierWithNumber
        case invalidNumberWithIdentifier
        case endCharIsOperator
        case consecutiveOperator
    }
    
    
    
    
    enum InputDicError: Error {
        case invalidInputFormat
        case notAnInteger
        case duplicateParameters
    }
    
    
  

    
    enum EvaluationError:String, Error {
        case variableNotDefined = "A variable is not defined for completing valuation"
        case tryingToDivideByZero
    }
    
    func hasPrecedence (op1: String, op2: String) -> Bool {
        if ((op1 == "*" || op1 == "/") && (op2 == "+" || op2 == "-")) {
            return false
        }
        return true
    }
    
    func applyOp(op: String, b: String, a:String) throws -> String {
        let b:Float! = Float(b)
        let a:Float! = Float(a)
        var result: Float = 0
        switch op {
        case "+":
            result = a + b
        case "-":
            result = a - b
        case "*":
            result = a * b
        case "/":
            if (b == 0) {
                throw EvaluationError.tryingToDivideByZero
            }
            result = a/b
        default:
            result = 0
        }
        return String(result)
    }
    

}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

