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
            brain.setOperand(Double(displayValue) ?? 0, with: displayValue)
            userIsInMiddleOfTyping = false
        }
        if let mathSymbol = sender.titleLabel?.text {
            brain.performOperation(for: mathSymbol)
        }
        if let result = brain.result {
            displayValue = String(result.d)
            if brain.resultIsPending {
                displayDescription = result.s + ellipsis
            } else {
                displayDescription = result.s + equals
                if sender.titleLabel?.text == randomSymbol {
                    displayDescription = String(displayValue)
                }
            }
        }
    }
    
    @IBAction func touchBackspace(_ sender: UIButton) {
        if displayValue.count > 1 {
            displayValue.removeLast()
        } else {
            displayValue = defaultValue
        }
    }
    
    @IBAction func touchCancel(_ sender: UIButton) {
        displayValue = defaultValue
        displayDescription = defaultValue
        brain = CalculatorBrain()
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
