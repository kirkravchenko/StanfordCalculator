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
    var userIsInMiddleOfTyping = false
    var dotButtonPressed = false
    var displayValue: String {
        get {
            return display.text!
        }
        set {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6
            formatter.usesGroupingSeparator = false
            display.text! = formatter.string(from: formatter.number(
                from: newValue)!)!
        }
    }
    
    @IBAction func TouchDigit(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        displayValue = process(
            title!, displayValue, userIsInMiddleOfTyping, dotButtonPressed
        )
        brain.appendToDescription(symbol: title!)
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        brain.appendToDescription(symbol: sender.titleLabel!.text!)
        if userIsInMiddleOfTyping {
            brain.setOperand(Double(displayValue)!)
            userIsInMiddleOfTyping = false
        }
        if let mathSymbol = sender.titleLabel?.text {
            brain.performOperation(for: mathSymbol)
        }
        if let result = brain.accumulator.d {
            displayValue = String(result)
        }
        resultDescription.text = brain.accumulator.s
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
