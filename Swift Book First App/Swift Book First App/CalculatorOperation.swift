//
//  Operation.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 19.11.2021.
//

import Foundation

extension CalculatorBrain {
    
    enum CalculatorOperation {
        
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        
        static func getOperation(by symbol: String) -> CalculatorOperation? {
            let operations: [String: CalculatorOperation] = [
                "π": .constant(Double.pi),
                "e": .constant(M_E),
                "C": .constant(0),
                "√": .unaryOperation(sqrt),
                "cos": .unaryOperation(cos),
                "sin": .unaryOperation(sin),
                "+/-": .unaryOperation(-),
                "✕": .binaryOperation(*),
                "÷": .binaryOperation(/),
                "+": .binaryOperation(+),
                "-": .binaryOperation(-),
                "=": .equals
            ]
            return operations[symbol]
        }
    }
}
