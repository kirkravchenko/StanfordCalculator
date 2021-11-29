//
//  CalculatorBrain.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 11.11.2021.
//

import Foundation

class CalculatorBrain {
    
    var accumulator: (d: Double?, s: String?)
    private var description = ""
    private struct PendingBinaryOperation {
        var function: (Double,Double) -> Double
        var formattingFunction: (String, String) -> String
        var firstOperand: Double
        var stringRepresentation: String
        var unaryOperationInside = false
        func perform (with secondOperand: Double) -> Double {
            return function (firstOperand, secondOperand)
        }
    }
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    private let ellipsis = "..."
    private let equals = "="
    private let empty = ""
    
    private func  performPendingBinaryOperation() {
        if resultIsPending && accumulator.d != nil {
            if pendingBinaryOperation!.unaryOperationInside {
                accumulator.s = pendingBinaryOperation!.stringRepresentation
                    .replacingOccurrences(of: ellipsis, with: equals)
                pendingBinaryOperation!.unaryOperationInside = false
            } else {
                accumulator.s = pendingBinaryOperation!.formattingFunction(     // formattingFunction takes first String parameter
                    pendingBinaryOperation!.stringRepresentation                // representing first operand and operation sign
                        .replacingOccurrences(                                  // (e.g. "7+")
                            of: ellipsis, with: empty                           // second operand is second operand value
                        ),
                    accumulator.d!.isEqual(to: Double.pi) ? "π" :
                        accumulator.d!.isEqual(to: M_E) ? "e" :
                        String(accumulator.d!)
                )
            }
            accumulator.d = pendingBinaryOperation!.perform(with: accumulator.d!)
            pendingBinaryOperation = nil
            description = ""
         }
    }
        
    func performOperation(for symbol: String) {
        guard let operation = CalculatorOperation.getOperation(by: symbol) else {
            return
        }
        switch operation {
        case .constant(let value):
            accumulator = (value, symbol.elementsEqual("C") ? "0" : symbol)
            if symbol.elementsEqual("C") {
                description = empty
            }
        case .unaryOperation(let function, let formattingFunction):
            if accumulator.d != nil && accumulator.s != nil {
                var fisrtOperand = empty
                var result = empty
                if !resultIsPending {
                    fisrtOperand = accumulator.s!
                            .replacingOccurrences(of: equals, with: empty)
                    result = formattingFunction(fisrtOperand) + equals
                } else {
                    pendingBinaryOperation!.unaryOperationInside = true
                    fisrtOperand = pendingBinaryOperation!.stringRepresentation
                        .replacingOccurrences(of: ellipsis, with: empty)
                    result = fisrtOperand + formattingFunction(String(
                        accumulator.d!)) + ellipsis
                    pendingBinaryOperation!.stringRepresentation = result
                }
                accumulator = (function(accumulator.d!), result)
            }
        case .binaryOperation(let function, let formattingFunction):
            if accumulator.d != nil && accumulator.s != nil {
                pendingBinaryOperation = PendingBinaryOperation (
                    function: function, formattingFunction: formattingFunction,
                    firstOperand: accumulator.d!,
                    stringRepresentation: accumulator.s!
                        .replacingOccurrences(of: equals, with: empty)
                    + symbol + ellipsis
                )
                accumulator = (nil, pendingBinaryOperation!.stringRepresentation)
            }
        case .equals:
            performPendingBinaryOperation()
        }
    }
    
    func setOperand(_ operand: Double) {
        accumulator = (operand, String(operand))
    }
    
    func appendToDescription(symbol: String) {
        if symbol != equals {
            description.append(contentsOf: symbol)
        }
    }
}
