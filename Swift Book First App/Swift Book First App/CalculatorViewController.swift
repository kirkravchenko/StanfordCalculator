//
//  ViewController.swift
//  Swift Book First App
//
//  Created by Kyrylo Kravchenko on 09.11.2021.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var resultDescription: UILabel!
    
    @IBOutlet weak var variable: UILabel!
    
    @IBOutlet weak var graphButton: UIButton!
    
    private var brain = CalculatorBrain()
    private let ellipsis = "..."
    private let equals = "="
    private let dot = "."
    private let defaultValue = "0"
    private let randomSymbol = "?"
    private var operation: String?
    private var variableEntered = false
    var userIsInMiddleOfTyping = false
    var dotButtonPressed = false
    var variables: [String: Double] = [:]
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
        guard let mathSymbol = sender.titleLabel?.text else {
            return
        }
        operation = mathSymbol
        brain.set(operation: mathSymbol)
        displayResult()
    }
    
    func displayResult() {
        let (result, isPending, description, error) = brain.evaluate(using: variables)
        if let result = result {
            displayValue = String(result)
            if isPending {
                displayDescription = error == nil ? description + ellipsis : error!
            } else {
                displayDescription = error == nil ? description + equals : error!
                if variableEntered {
                    graphButton.isEnabled = true
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
            displayResult()
        }
    }
    
    @IBAction func touchCancel(_ sender: UIButton) {
        displayValue = defaultValue
        displayDescription = defaultValue
        displayVariable = defaultValue
        variables = [:]
        brain = CalculatorBrain()
    }
    
    @IBAction func touchVariable(_ sender: UIButton) {
        guard let label = sender.titleLabel,
              let labelText = label.text else {
            return
        }
        if labelText == "→M" {
            displayVariable = displayValue
            userIsInMiddleOfTyping = false
            variables = ["M": Double(displayValue)!]
            displayResult()
        } else if labelText == "M" {
            brain.set(variable: labelText)
            variableEntered = true
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GraphViewController {
            destinationVC.function = {
                let (result, _, _, _) = self.brain.evaluate(using: ["M": $0])
                return result ?? 0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
           graphButton.setTitleColor(.systemGray, for: .disabled)
           graphButton.isEnabled = false
       }
}
