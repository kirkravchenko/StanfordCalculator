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
    private var state: State = .init(
        first: nil,
        operation: nil,
        second: nil,
        pendingBinaryOp: nil
    )
    private struct State {
        var first: String?
        var operation: String?
        var second: String?
        var result: String?
        var pendingBinaryOp: ((Double, Double) -> Double)?
        var display: PrintDisplay? = .init(
            first: nil,
            operation: nil,
            second: nil,
            result: nil,
            currentResultString: nil
        )
    }
    private var previousOperation: State?
    
    func addSymbolForOperation(_ symbol: String) {
        if state.first == nil {
            state.first = symbol
            state.display?.first = symbol
        } else if state.operation == nil {
            state.operation = symbol
            state.display?.operation = symbol
        } else if state.second == nil {
            state.second = symbol
            state.display?.second = symbol
        }
    }
    
    func performOperation(for symbol: String) {
        guard let operation = CalculatorOperation.getOperation(by: symbol) else {
            return
        }
        guard var _ = state.display else {  // если записывать в переменную _(display), то в структура state.display не будет перезаписываться?
            return
        }
        switch operation {
        case .constant(let value):
            accumulator = (value, String(value))
        case .unaryOperation(let function):
            state.display!.isUnary = true
            if let first = state.first,
               let currentOperation = state.operation {
                if symbol != currentOperation {
                    if let second = state.second {
                        // x+√(y) унарная операция над вторым операндом
                        state.result = String(function(Double(second)!))
                        state.display!.operation = symbol
                        accumulator = (Double(state.result!)!,
                                       state.display!.resultString)
                    }
                } else {
                    // √(х) простая унарная операция
                    state.result = String(function(Double(first)!))
                    accumulator = (Double(state.result!)!,
                                   state.display!.resultString)
                }
            } else if previousOperation != nil {
                // √(x+y) унарная операция над результатом бинарной
                guard let previousOperation = previousOperation,
                      let display = previousOperation.display else {
                          return
                      }
                state.display!.first = display.first
                state.display!.pendingBinaryOp = display.pendingBinaryOp
                state.display!.second = display.second
                state.display!.operation = symbol
                state.display!.currentResultString = display.result
                state.result = String(function(Double(
                    state.display!.currentResultString!)!))
                accumulator = (Double(state.result!) ?? 0,
                               state.display!.resultString)
            }
            
            state.display!.isUnary = false
            previousOperation = state
            state = State() // безопасно ли так чистить состояние?
        case .binaryOperation(let function):
            state.pendingBinaryOp = function
            state.display!.pendingBinaryOp = symbol
            accumulator = (nil, state.display!.resultString)
        case .equals:
            guard let pendingBinaryOp = state.pendingBinaryOp,
                  let firstOp = state.first,
                  let secondOp = state.second else {
                      return
                  }
            state.result = String(pendingBinaryOp(Double(firstOp)!,
                                                  Double(secondOp)!))
            state.display!.result = state.result
            accumulator = (Double(state.display!.result!)!,
                           state.display!.resultString)
            previousOperation = state
            state = State()
        }
    }
    
    func setOperand(_ operand: Double) {
        accumulator = (operand, String(operand))
    }
}
