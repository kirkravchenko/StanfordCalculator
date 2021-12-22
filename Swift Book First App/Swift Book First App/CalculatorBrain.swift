//
//  CalculatorBrain.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 11.11.2021.
//

import Foundation

struct CalculatorBrain {
    @available(*, deprecated, message: "Deprecation description")
    private(set) var result: (d: Double, s: String)?
    private struct PendingBinaryOperation {
        var function: (Double,Double) -> Double
        var formatter: (String, String) -> String
        var validator: (Double, Double) -> String?
        var firstOperand: Double
        var stringRepresentation: String
        func perform(with secondOperand: Double) -> Double {
            function (firstOperand, secondOperand)
        }
        func performFormatting(with secondOperand: String) -> String {
            formatter(stringRepresentation, secondOperand)
        }
        func performValidating(with secondOperand: Double) -> String? {
            validator(firstOperand, secondOperand)
        }
    }
    @available(*, deprecated, message: "Deprecation description")
    private(set) var resultIsPending: Bool = false
    
    private enum Literal {
        case operand(Operand)
        case operation(Operation)
        case variable(Variable)
        
        struct Operand {
            let value: Double
            let description: String
        }

        struct Operation {
            let symbol: String
        }
        
        struct Variable {
            let key: String
        }
    }
    
    private var sequence: [Literal] = []
    
    typealias EvaluationResult = (result: Double?, isPending: Bool, description: String)
    typealias EvaluationWithErrorResult = (result: Double?, isPending: Bool, description: String, error: String?)

    func evaluate(using variables: Dictionary<String, Double> = [:]) -> EvaluationResult {
        let (result, isPending, description, _) = evaluate(using: variables)
        return (result, isPending, description)
    }
    
    func evaluate(using variables: Dictionary<String, Double> = [:]) -> EvaluationWithErrorResult {
        var accumulator: (d: Double?, s: String?)
        var pendingBinaryOperation: PendingBinaryOperation?
        var error: String?
        
        func set(_ operand: Literal.Operand) {
            accumulator = (operand.value, operand.description)
        }
        
        func set(_ variable: Literal.Variable) {
            accumulator = (variables[variable.key] ?? 0, variable.key)
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator.d != nil && accumulator.s != nil {
                error = pendingBinaryOperation!.performValidating(with: accumulator.d!)
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
            case .unaryOperation(let function, let formatter, let validator):
                if accumulator.d != nil && accumulator.s != nil {
                    error = validator(accumulator.d!)
                    accumulator = (function(accumulator.d!),
                                   formatter(accumulator.s!))
                }
            case .binaryOperation(let function, let formatter, let validator):
                if accumulator.d != nil && accumulator.s != nil {
                    pendingBinaryOperation = PendingBinaryOperation(
                        function: function, formatter: formatter,
                        validator: validator,
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
        }
        
        for literal in sequence {
            switch literal {
            case .operand(let operand):
                set(operand)
            case .variable(let variable):
                set(variable)
            case .operation(let operation):
                performOperation(for: operation.symbol)
            }
        }
        
        if let operation = pendingBinaryOperation {
            return (
                accumulator.d ?? operation.firstOperand,
                true,
                operation.performFormatting(with: accumulator.s ?? ""),
                error
            )
        } else {
            return (
                accumulator.d ?? 0,
                false,
                accumulator.s ?? "",
                error
            )
        }
    }
    
    mutating func set(operand: Double, with formatting: String) {
        sequence.append(.operand(.init(value: operand, description: formatting)))
    }
    
    mutating func set(variable: String) {
        sequence.append(.variable(.init(key: variable)))
    }
    
    mutating func set(operation: String) {
        sequence.append(.operation(.init(symbol: operation)))
    }
    
    mutating func undo() {
        guard !sequence.isEmpty else {
            return
        }
        
        sequence.removeLast()
    }
}
