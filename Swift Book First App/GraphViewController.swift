//
//  ViewController.swift
//  GraphingCalculator
//
//  Created by Kyrylo Kravchenko on 15.12.2021.
//

import UIKit

class GraphViewController: UIViewController {
        
    var function: ((Double) -> Double)?

    @IBOutlet weak var graphView: GraphView!{
        didSet {
            graphView.origin = CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
            if let function = function {
                graphView.function = function
            }
            let handler = #selector(GraphView.changeScale(byReactingTo:))
            let pitchRecognizer = UIPinchGestureRecognizer(target: graphView, action: handler)
            graphView.addGestureRecognizer(pitchRecognizer)
            let tapHandler = #selector(GraphView.changeOriginByTap(byReactingTo:))
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            let panHandler = #selector(GraphView.changeOriginByPan(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
        }
    }
}
