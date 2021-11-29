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
            display.text ?? ""
        }
        set {
            display.text = Self.formatter.string(from: Self.formatter.number(
                from: newValue)!)! // - TODO избавиться от форс анврапа
        }
    }
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    @IBAction func touchSymbol(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        if userIsInMiddleOfTyping && title!.elementsEqual(".")
            && !displayValue.contains(".") {
            display.text! += title!
        } else if !title!.elementsEqual(".") {
            displayValue = process(
                title!, displayValue, userIsInMiddleOfTyping, dotButtonPressed
            )
        }
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
