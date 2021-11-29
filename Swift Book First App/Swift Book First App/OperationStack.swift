//
//  OperationStack.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 25.11.2021.
//

//import Foundation
//
//extension CalculatorBrain {
//    struct OperationStack {
//        private var items: [CalculatorBrain.Operation?] = []
//        
//        func peek() -> CalculatorBrain.Operation? {
//            guard let topElement = items.first else {
//                fatalError("This stack is empty.")
//            }
//            return topElement!
//        }
//        
//        mutating func pop() -> CalculatorBrain.Operation? {
//            if !items.isEmpty {
//                return items.removeFirst()
//            } else {
//                return nil
//            }
//        }
//        
//        mutating func push(_ element: CalculatorBrain.Operation?) {
//            items.insert(element, at: 0)
//        }
//        
//        func joined() -> String {
//            if !items.isEmpty {
//                return items.map { op in op!.description }.joined()
//            } else {
//                return ""
//            }
//        }
//        
//        func count() -> Int {
//            return items.count
//        }
//        
//        mutating func reversed() {
//            items = items.reversed()
//        }
//    }
//}
