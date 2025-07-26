//
//  PieChartView.swift
//  Utilities
//
//  Created by Михаил Рычагов on 24.07.2025.
//

import UIKit

public final class PieChartView: UIView {
    //MARK: Private properties
    private var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }
    private var lineWidth: CGFloat = 16 {
        didSet { setNeedsDisplay() }
    }
    
    private var legendFont: UIFont = .systemFont(ofSize: 14)
    private var legendTextColor: UIColor = .secondaryLabel
    
    //MARK: Lyfecycle
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public methods
//    public func setEntitites(_ entitites: [Entity]) {
//        self.entities = entitites
//    }
    public func animateTransition(to newSlices: [Entity],
                                      duration totalDuration: CFTimeInterval = 1.0) {
            let oldSlices = self.entities

            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.fromValue = 0
            rotation.toValue = 2 * CGFloat.pi
            rotation.duration = totalDuration
            rotation.timingFunction = CAMediaTimingFunction(name: .linear)

            let fade = CAKeyframeAnimation(keyPath: "opacity")
            fade.values     = [1, 0, 0, 1]
            fade.keyTimes   = [0, 0.5, 0.5001, 1] as [NSNumber]
            fade.duration   = totalDuration
            fade.timingFunctions = [
              CAMediaTimingFunction(name: .linear),
              CAMediaTimingFunction(name: .linear),
              CAMediaTimingFunction(name: .linear)
            ]

            let group = CAAnimationGroup()
            group.animations = [rotation, fade]
            group.duration   = totalDuration
            group.isRemovedOnCompletion = true
            group.fillMode   = .forwards

            let midTime = CACurrentMediaTime() + totalDuration * 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration * 0.5) {
                self.entities = newSlices
            }

            self.layer.add(group, forKey: "rotateAndFade")
        }
    
    //MARK: Private methods
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let total = entities.reduce(0) { $0 + $1.value }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = min(rect.width, rect.height) / 2 - lineWidth
        var startAngle: CGFloat = -.pi / 2
        
        for (idx, entity) in entities.enumerated() {
            let endAngle = startAngle + (CGFloat(entity.value / total)) * 2 * .pi
            guard let segmentNumber = Constants.SegmetnsColors(rawValue: idx) else { return }
            let color = segmentNumber.color
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            path.lineWidth = lineWidth
            ctx.saveGState()
            color.setStroke()
            path.stroke()
            ctx.restoreGState()
            
            startAngle = endAngle
        }
        
        let inset: CGFloat = 48
        let legendOrigin = CGPoint(x: center.x - radius + inset,
                                   y: center.y - (CGFloat(entities.count) * (legendFont.lineHeight + 6)) / 2)
        
        for (idx, entity) in entities.enumerated() {
            let dotSize: CGFloat = 12
            let y = legendOrigin.y + CGFloat(idx) * (legendFont.lineHeight + 8)
            let dotRect = CGRect(x: legendOrigin.x,
                                 y: y,
                                 width: dotSize,
                                 height: dotSize)
            ctx.saveGState()
            guard let segment = Constants.SegmetnsColors(rawValue: idx) else { return }
            ctx.setFillColor(segment.color.cgColor)
            ctx.fillEllipse(in: dotRect)
            ctx.restoreGState()
            
            // текст
            let text = "\(Int(entity.value / total * 100))% \(entity.label)" as NSString
            let textOrigin = CGPoint(x: dotRect.maxX + 6, y: y)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: legendFont,
                .foregroundColor: legendTextColor
            ]
            let textRect = CGRect(x: textOrigin.x,
                                  y: textOrigin.y,
                                  width: rect.width - textOrigin.x - inset,
                                  height: legendFont.lineHeight)
            text.draw(in: textRect, withAttributes: attrs)
        }
    }
}

extension PieChartView {
    private enum Constants {
        enum SegmetnsColors: Int {
            case first
            case second
            case third
            case fourth
            case fifth
            case sixth
            
            var color: UIColor {
                switch self {
                case .first:
                    return UIColor(
                        red: 42.0 / 255.0,
                        green: 232.0 / 255.0,
                        blue: 129.0 / 255.0,
                        alpha: 1.0
                    )
                case .second:
                    return UIColor(
                        red: 252.0 / 255.0,
                        green: 227.0 / 255.0,
                        blue: 0.0 / 255.0,
                        alpha: 1.0
                    )
                case .third:
                    return .red
                case .fourth: return .blue
                case .fifth: return .systemPink
                case .sixth: return .gray
                }
            }
        }
    }
}
