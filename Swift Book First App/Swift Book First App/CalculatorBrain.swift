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
}
