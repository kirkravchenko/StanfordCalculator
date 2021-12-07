//
//  CalculatorBrain.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 11.11.2021.
//

import Foundation

struct CalculatorBrain {
    
    var description = ""
    @available(*, deprecated, message: "Deprecation description")
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
    @available(*, deprecated, message: "Deprecation description")
    var resultIsPending: Bool {
        pendingBinaryOperation != nil
    }
    
    private struct Literal {
        let value: Double?
        var description: String?
    }
    private var operations = [Literal]()
    
    private mutating func performPendingBinaryOperation() {
        if resultIsPending && accumulator.d != nil && accumulator.s != nil {
            accumulator = (
                pendingBinaryOperation!.perform(with: accumulator.d!),
                pendingBinaryOperation!.performFormatting(with: accumulator.s!)
            )
            pendingBinaryOperation = nil
        }
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil)
    -> (result: Double?, isPending: Bool, description: String) {
        if variables != nil {
            // substitute variables with values
        }
        let operations = self.operations
        var returnValue: (result: Double?, isPending: Bool,
                          description: String) = (0.0, false, "")
        var secondOp: Literal? = nil
        var result: Literal? = nil
        var pendingResult: Literal? = nil
        var pendingBinaryFunction: (function: (Double, Double) -> Double,
                                    formattingFunction: (String, String) -> String)? = nil
        
        for op in operations {
            if let operation = CalculatorOperation.getOperation(by: op.description!) {
                switch operation {
                case .constant(let value):
                    result = Literal(value: value, description: op.description!)
                case .unaryOperation(let function, let formattingFunction):
                    if returnValue.isPending {
                        secondOp = Literal(value: function(secondOp!.value!),
                                           description:formattingFunction(
                                            secondOp!.description!))
                        pendingResult = Literal(value: secondOp!.value,
                                                description: pendingBinaryFunction!.formattingFunction(
                                                    result!.description!, secondOp!.description!))
                    } else {
                        result = Literal(value: function(result!.value!),
                                         description: formattingFunction(
                                            result!.description!))
                    }
                case .binaryOperation(let function, let formattingFunction):
                    pendingBinaryFunction = (function, formattingFunction)
                    returnValue.isPending = true
                case .random(let function, let formattingFunction):
                    let random = function()
                    result = Literal(value: random,
                                     description: formattingFunction(random))
                case .equals:
                    if secondOp != nil && pendingBinaryFunction != nil {
                        result = Literal(value: pendingBinaryFunction!.function(
                            result!.value!, secondOp!.value!),
                                         description: pendingBinaryFunction!.formattingFunction(
                                            result!.description!, secondOp!.description!))
                        returnValue.isPending = false
                        secondOp = nil
                    }
                }
            } else {
                if result != nil && secondOp == nil {
                    secondOp = Literal(value: op.value!, description: op.description!)
                } else if result == nil {
                    result = Literal(value: op.value!, description: op.description!)
                }
            }
            if pendingResult != nil {
                returnValue.result = pendingResult!.value
                returnValue.description = pendingResult!.description!
                pendingResult = nil
            } else if result != nil {
                returnValue.result = result!.value
                returnValue.description = result!.description!
            }
        }
        return returnValue
    }
    
    mutating func setOperand(_ operand: Double, with formatting: String) {
        operations.append(Literal(value: operand, description: formatting))
    }
    }
    
    func setOperand(_ operand: Double, with formatting: String) {
        accumulator = (operand, formatting)
    }
}
