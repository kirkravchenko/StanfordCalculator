//
//  CalculatorBrain.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 11.11.2021.
//

import Foundation

// отдельный файл для логики построения стринги

// поменять на класс
struct CalculatorBrain {
    // 2 метода
    // инпут (паблик)
    // аутпут (паблик)
    
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var opsSequence: [String] = []
    private var pendingBinaryOps: [String] = []
    var accumulator: (d: Double?, s: String?) {
        didSet {
            if let operand = accumulator.s {
                if !operand.contains("...") {
                    opsSequence.append(operand)
                    print("ops")
                    print(opsSequence)
                    print("pendingBinaryOps")
                    print(pendingBinaryOps)
                }
            }
        }
    }
    
    public mutating func appendAfterDot(to afterDotNumber: String) {
        let splitDouble = String(accumulator.d ?? 0).components(separatedBy: ".")
        let beforeDot = splitDouble[0]
        let afterDot = splitDouble[1] == "0"
        ? afterDotNumber
        : splitDouble[1] + afterDotNumber
        accumulator = (Double("\(beforeDot).\(afterDot)")!, "\(beforeDot).\(afterDot)")
    }
    
    // вынести в экстенш
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: [String: Operation] = [
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
    
    // мне нужно изолировать обработну унарной и бинарной операции
    // в то же время надо обрабатывать унарные операции внутри бинарных
    
    mutating func performOperation(for symbol: String) {
        guard let operation = operations[symbol] else {
            return
        }
        
        switch operation {
        case .constant(let value):
            accumulator = (value, String("\(value) " + symbol))
        case .unaryOperation(let function) where accumulator.d != nil && accumulator.s != nil:
            // варианты унарных операций:
            // 1) изолированая, на одном числе - просто
            // 2) унарная операция над бинарным результатом
            // 3) унарная операция над одним из операндов бинарной операции
            
            // как различить каждую?
            if let accumDouble = accumulator.d,
               let accumString = accumulator.s {
                let result = function(accumDouble)
                if opsSequence.count == 1 {
                    opsSequence.insert(symbol, at: 0)
                    accumulator = (result, opsSequence.joined())
                    opsSequence.removeAll()
                } else if pendingBinaryOps.count == 2 {
                    accumulator = (result, pendingBinaryOps.joined() + symbol + "(" + accumString + ")")
                    let lastOp = opsSequence.last ?? ""
                    opsSequence.removeAll()
                    opsSequence.append(lastOp)
                } else if pendingBinaryOps.count == 3 {
                    accumulator = (result, symbol + "(" + pendingBinaryOps.joined() + ")=")
                    opsSequence.removeAll()
                }
            }
        case .binaryOperation(let function):
            if accumulator.d != nil {
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.d!)
                opsSequence.append(symbol)
                accumulator = (nil, accumulator.s! + symbol + "...")
                pendingBinaryOps = opsSequence
            }
        case .equals:
            performPendingBinaryOperation()
        case .unaryOperation:
            assertionFailure()
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.d != nil {
            let result = pendingBinaryOperation!.perform(with: accumulator.d!)
            pendingBinaryOps = opsSequence
            accumulator = (result, "=")
            accumulator.s = opsSequence.joined()
            pendingBinaryOperation = nil
            opsSequence.removeAll()
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        mutating func perform(with secondOperand: Double) -> Double {
            function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, String(operand))
    }
    
    var result: Double? {
        accumulator.d
    }
    
    private func getOperationString(fromArray: [String]) -> String {
        fromArray.joined()
    }
}
