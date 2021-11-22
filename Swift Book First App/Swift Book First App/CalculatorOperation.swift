//
//  Operation.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 19.11.2021.
//

import Foundation

extension CalculatorBrain {
    
    // недоступен из calculator brain когда приват
    enum CalculatorOperation {
        
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        
        static func getOperation(by symbol: String) -> CalculatorOperation? {
            let operations: [String: CalculatorOperation] = [
                "π": .constant(Double.pi),
                "e": .constant(M_E),
                "√": .unaryOperation(sqrt),
                "cos": .unaryOperation(cos),
                "sin": .unaryOperation(sin),
                "+/-": .unaryOperation({ -$0 }),
                "✕": .binaryOperation({ $0 * $1 }),
                "÷": .binaryOperation({ $0 / $1 }),
                "+": .binaryOperation({ $0 + $1 }),
                "-": .binaryOperation({ $0 - $1 }),
                "=": .equals
            ]
            return operations[symbol]
        }
    }
}
