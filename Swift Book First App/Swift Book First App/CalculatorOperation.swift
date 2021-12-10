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
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
        case random(() -> Double, (Double) -> String)
        
        static func getOperation(by symbol: String) -> CalculatorOperation? {
            let operations: [String: CalculatorOperation] = [
                "π": .constant(Double.pi),
                "e": .constant(M_E),
                "C": .constant(0),
                "√": .unaryOperation(sqrt, { "√(\($0))" }),
                "cos": .unaryOperation(cos, { "cos(\($0))" }),
                "sin": .unaryOperation(sin, { "sin(\($0))" }),
                "+/-": .unaryOperation(-, { "\(-(Double($0)!))" }),
                "✕": .binaryOperation(*, { "\($0)✕\($1)" }),
                "÷": .binaryOperation(/, { "\($0)÷\($1)" }),
                "+": .binaryOperation(+, { "\($0)+\($1)" }),
                "-": .binaryOperation(-, { "\($0)-\($1)" }),
                "=": .equals,
                "?": .random({ Double.random(in: 0.0 ..< 1.0) }, { String($0) })
            ]
            return operations[symbol]
        }
    }
}
