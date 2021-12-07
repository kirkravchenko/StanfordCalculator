//
//  CalculatorBrain.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 11.11.2021.
//

import Foundation

class CalculatorBrain {
    private(set) var result: (d: Double, s: String)?
    private var accumulator: (d: Double?, s: String?)
    private struct PendingBinaryOperation {
        var function: (Double,Double) -> Double
        var formattingFunction: (String, String) -> String
        var firstOperand: Double
        var stringRepresentation: String
        func perform(with secondOperand: Double) -> Double {
            function (firstOperand, secondOperand)
        }
        func performFormatting(with secondOperand: String) -> String {
            formattingFunction(stringRepresentation, secondOperand)
        }
    }
    private var pendingBinaryOperation: PendingBinaryOperation?
    var resultIsPending: Bool {
        pendingBinaryOperation != nil
    }
    private func  performPendingBinaryOperation() {
        if resultIsPending && accumulator.d != nil && accumulator.s != nil {
            accumulator = (
                pendingBinaryOperation!.perform(with: accumulator.d!),
                pendingBinaryOperation!.performFormatting(with: accumulator.s!)
            )
            pendingBinaryOperation = nil
        }
    }
    
//    private struct LiteralOperand {
//        let value: Double
//        let description: String
//    }
//
//    private struct LiteralOperation {
//        let symbol: String
//    }
    
    private enum Literal {
        case operand(value: Double, formatting: String)
        case operation(symbol: String)
    }
    
    private var sequence: [Literal] = []
    
    // enum == OR
    // struct == AND
    
    // Literal as struct = Double * String
    
    typealias EvaluationResult = (result: Double?, isPending: Bool, description: String)
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> EvaluationResult {
        
        
        return (nil, false, "")
    }
    
    func performOperation(for symbol: String) {
        guard let operation = CalculatorOperation.getOperation(by: symbol) else {
            return
        }
        switch operation {
        case .constant(let value):
            accumulator = (value, symbol)
        case .unaryOperation(let function, let formattingFunction):
            if accumulator.d != nil && accumulator.s != nil {
                accumulator = (function(accumulator.d!),
                               formattingFunction(accumulator.s!))
            }
        case .binaryOperation(let function, let formattingFunction):
            if accumulator.d != nil && accumulator.s != nil {
                pendingBinaryOperation = PendingBinaryOperation (
                    function: function, formattingFunction: formattingFunction,
                    firstOperand: accumulator.d!,
                    stringRepresentation: accumulator.s!
                )
                accumulator = (nil, nil)
            }
        case .random(let function, let formattingFunction):
            let randomValue = function()
            accumulator = (randomValue, formattingFunction(randomValue))
        case .equals:
            performPendingBinaryOperation()
        }
        if let operation = pendingBinaryOperation {
            result = (accumulator.d ?? operation.firstOperand,
                      operation.performFormatting(with: accumulator.s ?? ""))
        } else {
            result = (accumulator.d ?? 0, accumulator.s ?? "")
        }
    }
    
    func setOperand(_ operand: Double, with formatting: String) {
        accumulator = (operand, formatting)
    }
    
    func setOperation(_ operation: String) {
        // ?
    }
    
//    mutating func undo() {
//        guard !operations.isEmpty else {
//            return
//        }
//
//        let operation = operations.removeLast()
//        if operation.description == "=" {
//            operations.removeLast()
//        }
//        // implement before evaluate and variable
//    }
}
