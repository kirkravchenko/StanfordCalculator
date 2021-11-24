import Foundation

protocol Operator {
    var value: Double { get }
    var result: Double { get }
    var description: String { get }
}

extension CalculatorBrain {
    
    struct NumberOperator: Operator {
        let value: Double
        let result: Double
        let description: String
        
        init(_ value: Double) {
            self.value = value
            self.result = value
            self.description = String(value)
        }
    }
    
    struct UnaryOperator: Operator {
        let value: Double
        let result: Double
        let description: String
        
        init(value: Double, symbol: String, result: Double) {
            self.value = value
            self.result = result
            self.description = String("\(symbol)(\(value))")
        }
    }
    
    struct BinaryOperator: Operator {
        let value: Double
        let secondValue: Double
        let result: Double
        let description: String
        
        init(
            value: Operator,
            secondValue: Operator,
            symbol: String,
            result: Double
        ) {
            self.value = value.result
            self.secondValue = secondValue.result
            self.result = result
            self.description = String(
                "(\(value.description) \(symbol) \(secondValue.description))"
            )
        }
    }
}
