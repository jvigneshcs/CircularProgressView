//
//  CircularProgressView.swift
//  Custom Views
//
//  Created by Vignesh J on 20/01/16.
//  Copyright © 2016 Vignesh J. All rights reserved.
//

import UIKit

let π = CGFloat(Double.pi)

enum ArcStartLocation: Int {
    case Top;
    case Right;
    case Bottom;
    case Left;
}

@objc
@IBDesignable class CircularProgressView: UIView {

    @IBInspectable var ringBackgroundColour: UIColor = .lightGray
    @IBInspectable var ringForegroundColour: UIColor = .green
    @IBInspectable var progressLabelColor: UIColor = .black
    
    @IBInspectable var foreGroundArcWidth: CGFloat = 8
    @IBInspectable var backGroundArcWidth: CGFloat = 8
    @IBInspectable var animateProgress: Bool = false
    @IBInspectable var displayProgressTextually: Bool = false
    
    @IBInspectable var selectedValue: UInt8 = 0 {
        didSet {
            let value = max(0, min(selectedValue, 100))
            animateScale = Float(value) / 100
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var arcStartLocation: Int {
        set(newValue) {
            if newValue < 0 || newValue > 3 {
                internalArcStartLocation = 0
            } else {
                internalArcStartLocation = newValue
            }
        }
        get {
            return internalArcStartLocation
        }
    }
    
    private var arcMargin: CGFloat = 0
    private var animateScale: Float = 0 // must be between [0,1]
    private var progressIndicatorLabel = UILabel()
    private var internalArcStartLocation = 0
    
	override func draw(_ rect: CGRect) {
		backgroundArc()
        if animateProgress {
            animateArc(value: CGFloat(animateScale))
        } else {
            foregroundArc()
        }
    }
    
    private func calcStartAngle(arcStartLocation: ArcStartLocation) -> CGFloat {
        let startAngle: CGFloat
        switch arcStartLocation {
        case .Top:
            startAngle = -(π / 2)
        case .Right:
            startAngle = 0
        case .Bottom:
            startAngle = -(3 * π / 2)
        case .Left:
            startAngle = -π
        }
        return startAngle
    }
    
    private func calcStartEndAngle(arcStartLocation: ArcStartLocation, progressValue: CGFloat) -> (startAngle: CGFloat, endAngle: CGFloat) {
        let startAngle = calcStartAngle(arcStartLocation: arcStartLocation)
        let endAngle = π * 2 * progressValue + startAngle
        return (startAngle, endAngle)
    }
    
    private func calcStartEndAngle(arcStartLocation: ArcStartLocation) -> (startAngle: CGFloat, endAngle: CGFloat) {
        return calcStartEndAngle(arcStartLocation: arcStartLocation, progressValue: 1)
    }
    
    private func centerAndRadius() -> (center: CGPoint, radius: CGFloat) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let diameter = max(bounds.width - arcMargin, bounds.height - arcMargin)
        let radius = diameter / 2 - max(foreGroundArcWidth, backGroundArcWidth) / 2
        return (center, radius)
    }
    
    private func drawArc(startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat, ringColor: UIColor) {
        let centerNRadius = centerAndRadius()
        let center = centerNRadius.center
        let radius = centerNRadius.radius
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = lineWidth
        ringColor.setStroke()
        path.stroke()
    }

	private func backgroundArc() {
        let startAngle: CGFloat = 0
        let endAngle: CGFloat =  2 * π
        
        drawArc(startAngle: startAngle, endAngle: endAngle, lineWidth: backGroundArcWidth, ringColor: ringBackgroundColour)
	}
    
    private func foregroundArc() {
        let startLocation: ArcStartLocation = ArcStartLocation(rawValue: internalArcStartLocation)!
        let startEndAngle = calcStartEndAngle(arcStartLocation: startLocation, progressValue: CGFloat(animateScale))
        let startAngle = startEndAngle.startAngle
        let endAngle = startEndAngle.endAngle
        
        drawArc(startAngle: startAngle, endAngle: endAngle, lineWidth: foreGroundArcWidth, ringColor: ringForegroundColour)
        displayProgressText(forValue: CGFloat(animateScale))
    }
    
    private func animateArc(value: CGFloat) {
        let loaderValue = (value == 0) ? CGFloat(0.01) : value
        let centerNRadius = centerAndRadius()
        let center = centerNRadius.center
        let radius = centerNRadius.radius
        let startLocation = ArcStartLocation(rawValue: internalArcStartLocation)!
        let startEndAngle = calcStartEndAngle(arcStartLocation: startLocation)
        let startAngle = startEndAngle.startAngle
        let endAngle = startEndAngle.endAngle
        let arcPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let ringLayer = CAShapeLayer()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = 2
        animation.fromValue = 0
        animation.toValue = loaderValue // changed here
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

        ringLayer.path = arcPath.cgPath
        ringLayer.strokeColor = ringForegroundColour.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = foreGroundArcWidth
        ringLayer.strokeEnd = 0.0
        layer.addSublayer(ringLayer)

		ringLayer.strokeEnd = loaderValue
		ringLayer.add(animation, forKey: "animateArc")
        
        displayProgressText(forValue: loaderValue)
	}
    
    private func displayProgressText(forValue loaderValue: CGFloat) {
        progressIndicatorLabel.isHidden = !displayProgressTextually
        if !displayProgressTextually {
            return
        }
        progressIndicatorLabel.frame = CGRect(x: self.frame.size.width / 2 - 60, y: self.frame.size.height / 2 - 34, width: 120, height: 68)
        progressIndicatorLabel.textColor = progressLabelColor
        progressIndicatorLabel.textAlignment = .center
        
        let value = Int(loaderValue * 100)
        let attributedString = NSMutableAttributedString(string: "\(value)%")
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14.0), range: NSMakeRange(attributedString.length - 1, 1))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16.0), range: NSMakeRange(0, attributedString.length - 1))
        
        self.progressIndicatorLabel.attributedText = attributedString
        self.addSubview(progressIndicatorLabel)
    }
}
