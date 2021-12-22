//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Kyrylo Kravchenko on 15.12.2021.
//

import UIKit

class GraphView: UIView {
    
    var origin: CGPoint = .zero
    
    private var offset: CGPoint = .zero
    
    private var previousTranslation: CGPoint = .zero
    
    override var bounds: CGRect {
        willSet {
            offset.x /= bounds.width / newValue.width
            offset.y /= bounds.height / newValue.height
            origin = CGPoint(x: newValue.midX + offset.x, y: newValue.midY + offset.y)
            setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        // look up frame setting in split view
        didSet {
            self.bounds = bounds
        }
    }
    
    var function: ((Double) -> Double) = {
        $0
    }
    
    var pointsPerUnit: CGFloat = 40.0
    let originalPointsPerUnit: CGFloat = 40.0
    
    @IBInspectable
    var scale: CGFloat = 1.0
    
    var lineWidth = 1.0
    
    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
        pointsPerUnit = originalPointsPerUnit * scale
        setNeedsDisplay()
    }
    
    @objc func changeOriginByTap(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        origin = tapRecognizer.location(in: self)
        offset.x = origin.x - bounds.midX
        offset.y = origin.y - bounds.midY
        setNeedsDisplay()
    }
    
    private(set) var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.minimumIntegerDigits = 3
        formatter.plusSign = "+"
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @objc func changeOriginByPan(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed:
            let translation = panRecognizer.translation(in: self)
            let delta = CGPoint(x: translation.x - previousTranslation.x,
                                y: translation.y - previousTranslation.y)
            origin.applyPanning(
                for: delta, ratio: 1
            )
            previousTranslation = translation
        case .ended:
            offset.x = origin.x - bounds.midX
            offset.y = origin.y - bounds.midY
            previousTranslation = .zero
        default:
            break
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        AxesDrawer().drawAxes(in: bounds, origin: origin, pointsPerUnit: pointsPerUnit)
        pathForFunction().stroke()
    }
    
    private func pathForFunction() -> UIBezierPath {
        
        func convertCoordinates(_ x: Double) -> Double {
            return (x / pointsPerUnit) - ((bounds.width / pointsPerUnit) / (bounds.width / origin.x))
        }
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var x = CGFloat(0)
        path.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        while x < bounds.width {
            let y = function(convertCoordinates(x))
            if !y.isNaN {
                path.addLine(
                    to: CGPoint(
                        x: x,
                        y: origin.y - (pointsPerUnit * y)
                    )
                )
            } else {
                path.move(to: CGPoint(x: x, y: origin.y - (pointsPerUnit * 0)))
            }
            x += 1
        }
        return path
    }

}

extension CGPoint {
    
    mutating func applyPanning(for point: CGPoint, ratio: CGFloat = 20) {
        self.x += point.x / ratio
        self.y += point.y / ratio
    }
}
