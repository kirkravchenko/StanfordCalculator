//
//  ViewController.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 09.11.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var resultDescription: UILabel!
    
    @IBOutlet weak var variable: UILabel!
    
    private var brain = CalculatorBrain()
    private let ellipsis = "..."
    private let equals = "="
    private let dot = "."
    private let defaultValue = "0"
    private let randomSymbol = "?"
    var userIsInMiddleOfTyping = false
    var dotButtonPressed = false
    var displayDescription: String {
        get {
            resultDescription.text ?? defaultValue
        }
        set {
            resultDescription.text = newValue
        }
    }
    var displayValue: String {
        get {
            display.text ?? defaultValue
        }
        set {
            display.text = Self.formatter.string(
                from: Self.formatter.number(
                    from: newValue) ?? 0) ?? defaultValue
        }
    }
    var displayVariable: String {
        get {
            variable.text ?? defaultValue
        }
        set {
            variable.text = newValue
        }
    }
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    @IBAction func touchSymbol(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        if userIsInMiddleOfTyping && title.elementsEqual(dot)
            && !displayValue.contains(dot) {
            display.text! += title
        } else if !title.elementsEqual(dot) {
            displayValue = process(
                title, displayValue, userIsInMiddleOfTyping, dotButtonPressed
            )
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            brain.set(operand: Double(displayValue) ?? 0, with: displayValue)
            userIsInMiddleOfTyping = false
        }
        if let mathSymbol = sender.titleLabel?.text {
            brain.set(operation: mathSymbol)
        }
        
        let (result, isPending, description) = brain.evaluate(using: nil)
        if let result = result {
            displayValue = String(result)
            if isPending {
                displayDescription = description + ellipsis
            } else {
                displayDescription = description + equals
                if sender.titleLabel?.text == randomSymbol {
                    displayDescription = String(displayValue)
                }
            }
        }
    }
    
    @IBAction func touchBackspace(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            if displayValue.isEmpty {
                displayValue = defaultValue
            } else {
                displayValue.removeLast()
            }
        } else {
            brain.undo()
            
            let (result, isPending, description) = brain.evaluate(using: nil)
            if let result = result {
                displayValue = String(result)
                if isPending {
                    displayDescription = description + ellipsis
                } else {
                    displayDescription = description + equals
                    if sender.titleLabel?.text == randomSymbol {
                        displayDescription = String(displayValue)
                    }
                }
            }
        }
    }
    
    @IBAction func touchCancel(_ sender: UIButton) {
        displayValue = defaultValue
        displayDescription = defaultValue
        brain = CalculatorBrain()
    }
    
    @IBAction func touchVariable(_ sender: UIButton) {
        guard let label = sender.titleLabel,
              let labelText = label.text else {
            return
        }
        if labelText == "→M" {
            displayVariable = displayValue
            let (result, isPending, description) =
            brain.evaluate(using: ["M": Double(displayValue)!])
            if let result = result {
                displayValue = String(result)
                if isPending {
                    displayDescription = description + ellipsis
                } else {
                    displayDescription = description + equals
                    if sender.titleLabel?.text == randomSymbol {
                        displayDescription = String(displayValue)
                    }
                }
            }
        } else if labelText == "M" {
            brain.set(variable: labelText)
        }
    }
    
    func process(
        _ title: String,
        _ displayedText: String,
        _ userIsInMiddleOfTyping: Bool,
        _ dotButtonPressed: Bool
    ) -> String {
        if userIsInMiddleOfTyping {
            return displayedText + title
        } else {
            self.userIsInMiddleOfTyping = true
            return title
        }
    }
}
