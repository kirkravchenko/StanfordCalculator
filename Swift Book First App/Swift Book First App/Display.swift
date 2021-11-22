//
//  Display.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 20.11.2021.
//

import UIKit

extension CalculatorBrain {
    struct PrintDisplay {
        var isUnary = false
        private let elipsies = "..."
        private let equal = "="
        private let openParenthesis = "("
        private let closeParenthesis = ")"
        var resultString: String {
            var printResult = ""
            switch option {
            case .empty:
                return ""
            case .onlyFirst:
                return first!
            case .firstAndOperation:
                printResult.append(first!)
                printResult.append(operation!)
                printResult.append(elipsies)
                return printResult
            case .unaryResult:
                if second == nil {
                    printResult.append(operation!)
                    printResult.append(openParenthesis)
                    printResult.append(first!)
                    printResult.append(closeParenthesis)
                    printResult.append(equal)
                } else if currentResultString == nil {
                    printResult.append(first!)
                    printResult.append(pendingBinaryOp!)
                    printResult.append(operation!)
                    printResult.append(openParenthesis)
                    printResult.append(second!)
                    printResult.append(closeParenthesis)
                } else {
                    printResult.append(operation!)
                    printResult.append(openParenthesis)
                    printResult.append(first!)
                    printResult.append(pendingBinaryOp!)
                    printResult.append(second!)
                    printResult.append(closeParenthesis)
                    printResult.append(equal)
                }
                return printResult
            case .final:
                printResult.append(first!)
                printResult.append(operation!)
                printResult.append(second!)
                printResult.append(equal)
                return printResult
            }
        }
        
        var first: String?
        var operation: String?
        var second: String?
        var result: String?
        var currentResultString: String?
        var pendingBinaryOp: String?
        
        private var option: Option {
            if first == nil {
                return .empty
            } else if operation == nil {
                return .onlyFirst
            } else if second == nil {
                if isUnary {
                    return .unaryResult
                }
                return .firstAndOperation
            } else {
                if isUnary {
                    return .unaryResult
                }
                return .final
            }
        }
        
        private enum Option {
            case empty, onlyFirst, firstAndOperation, final, unaryResult
        }
    }
}
