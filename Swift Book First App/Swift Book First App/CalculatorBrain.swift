//
//  CalculatorBrain.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 11.11.2021.
//

import Foundation

class CalculatorBrain {
    
    var accumulator: (d: Double?, s: String?)
    var result: Double? {
        accumulator.d
    }
    
    private var currentState: State = .init(
        first: nil,
        operation: nil,
        second: nil,
        result: nil,
        pendingBinaryOp: nil
    )
    struct State {
        var first: Operator?
        var operation: String?
        var second: Operator?
        var result: Operator?
        var pendingBinaryOp: ((Double, Double) -> Double)?
    }
    var stateStack = StateStack()
    
    func addSymbolForOperation(_ symbol: String) {
        if currentState.first == nil && currentState.operation == nil {
            guard let numberOperand = Double(symbol) else {
                currentState.operation = symbol
                return
            }
            currentState.first = NumberOperator(numberOperand)
        } else if currentState.operation == nil {
            currentState.operation = symbol
        } else if currentState.second == nil {
            guard let numberOperand = Double(symbol) else {
                currentState.operation = symbol
                return
            }
            currentState.second = NumberOperator(numberOperand)
        }
    }
    
    func performOperation(for symbol: String) {
        guard let operation = CalculatorOperation.getOperation(by: symbol) else {
            return
        }
        switch operation {
        case .constant(let value):
            accumulator = (value, String(value))
            currentState = State()
        case .unaryOperation(let function):
            performUnaryOp(function, symbol)
        case .binaryOperation(let function):
            set(function, andOperation: symbol)
        case .equals:
            performBinaryOp()
        }
    }
    
    func performUnaryOp(_ function: (Double) -> Double, _ symbol: String) {
        if var first = currentState.first,
           let currentOperation = currentState.operation {
            if symbol != currentOperation {
                if var second = currentState.second {
                    second = UnaryOperator(value: second.value,
                                           symbol: symbol,
                                           result: function(second.value))
                    currentState.second = second
                    guard let firstOp = currentState.first,
                          let secondOp = currentState.second,
                          let operation = currentState.operation else {
                              assertionFailure()
                              return
                          }
                    accumulator = (secondOp.result, firstOp.description +
                                   operation + secondOp.description)
                } else {
                    assertionFailure()
                }
            } else {
                first = UnaryOperator(value: first.value,
                                      symbol: symbol,
                                      result: function(first.value))
                currentState.result = first
                accumulator = (first.result, first.description + "=")
                stateStack.push(currentState)
                currentState = State()
            }
        } else {
            let previousState = stateStack.peek()
            guard let previousOp = previousState.result as Operator? else {
                assertionFailure()
                return
            }
            let unaryOp = UnaryOperator(value: previousOp.result,
                                        symbol: symbol,
                                        result: function(previousOp.result))
            currentState.result = unaryOp
            accumulator = (unaryOp.result, symbol +
                           previousOp.description + "=")
            stateStack.push(currentState)
            currentState = State()
        }
    }
    
    func set(_ function: @escaping (Double, Double) -> Double,
             andOperation symbol: String) {
        currentState.pendingBinaryOp = function
        if currentState.first == nil {
            let previousState = stateStack.peek()
            currentState.first = previousState.result
        }
        guard let firstOperand = currentState.first else {
            assertionFailure()
            return
        }
        accumulator = (nil, firstOperand.description +
                       symbol + "...")
    }
    
    func performBinaryOp() {
        guard let firstOp = currentState.first,
              let secondOp = currentState.second,
              let operation = currentState.operation,
              let pendingbinaryOp = currentState.pendingBinaryOp else {
                  assertionFailure()
                  return
              }
        let binaryOp = BinaryOperator(
            value: firstOp, secondValue: secondOp,
            symbol: operation,
            result: pendingbinaryOp(
                currentState.first!.result, currentState.second!.result
            )
        )
        currentState.result = binaryOp
        accumulator = (binaryOp.result, binaryOp.description + "=")
        stateStack.push(currentState)
        currentState = State()
    }
    
    func setOperand(_ operand: Double) {
        accumulator = (operand, String(operand))
    }
}
