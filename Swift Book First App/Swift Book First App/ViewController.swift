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
    var displayValue: Double {
        get {
            Double(display.text!)!
        }
        set {
            display.text! = String(newValue)
        }
    }
    
    @IBAction func TouchDigit(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        display.text! = process(
            title!, displayValue, userIsInMiddleOfTyping, dotButtonPressed
        )
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            brain.setOperand(displayValue)
            brain.addSymbolForOperation(String(displayValue))
            userIsInMiddleOfTyping = false
        }
        if let mathSymbol = sender.titleLabel?.text {
            brain.addSymbolForOperation(mathSymbol)
            brain.performOperation(for: mathSymbol)
            if mathSymbol == "." {
                dotButtonPressed = true
            } else {
                dotButtonPressed = false
            }
        }
        if let result = brain.result {
            displayValue = result
        }
        resultDescription.text = brain.accumulator.s
    }
    
    func process(
        _ title: String,
        _ displayedText: Double,
        _ userIsInMiddleOfTyping: Bool,
        _ dotButtonPressed: Bool
    ) -> String {
        if userIsInMiddleOfTyping {
            return String(displayedText).components(separatedBy: ".")[0] + title
        } else {
            self.userIsInMiddleOfTyping = true
            return title
        }
    }
}
