//
//  OperatorStack.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 24.11.2021.
//

import Foundation

extension CalculatorBrain {
    struct StateStack {
        private var items: [CalculatorBrain.State?] = []
        
        func peek() -> CalculatorBrain.State {
            guard let topElement = items.first else {
                fatalError("This stack is empty.")
            }
            return topElement!
        }
        
        mutating func pop() -> CalculatorBrain.State? {
            return items.removeFirst()
        }
        
        mutating func push(_ element: CalculatorBrain.State?) {
            items.insert(element, at: 0)
        }
    }
}
