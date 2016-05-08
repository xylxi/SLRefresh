//
//  SLRefreshHeaderView.swift
//  SLRefreshDemo
//
//  Created by WangZHW on 16/5/8.
//  Copyright © 2016年 RobuSoft. All rights reserved.
//

import UIKit
import CoreText


public class HeaderView: UIView {
    private var textProgressLayer: CAShapeLayer!
    private var textgradientLayer: CAGradientLayer!
    private let progressText: String
    private let gradientText: String
    private let highColor: UIColor = {
        return UIColor(red: CGFloat(224)/CGFloat(255), green: CGFloat(95)/CGFloat(255), blue: CGFloat(95)/CGFloat(255), alpha: 1.0)
    }()
    let normalColor: UIColor = {
        return UIColor(red: CGFloat(238)/CGFloat(255), green: CGFloat(220)/CGFloat(255), blue: CGFloat(220)/CGFloat(255), alpha: 1.0)
    }()
    public init(frame: CGRect,progressText: String,gradientText: String) {
        self.progressText = progressText
        self.gradientText = gradientText
        super.init(frame: frame)
        self.setupTextProgressLayer()
    }
    
    private func setupTextProgressLayer() {
        if self.textProgressLayer == nil {
            let textPath = CGPathCreateMutable()
            
            let font = CTFontCreateWithName("HelveticaNeue-UltraLight", 21, nil)
            // 可能有问题
            let attributes: [String: AnyObject] = [
                NSForegroundColorAttributeName : UIColor.darkGrayColor().CGColor,
                NSFontAttributeName : font
            ]
            
            let attributeString = NSAttributedString(string: self.progressText, attributes: attributes)
            let line = CTLineCreateWithAttributedString(attributeString);
            // 转换要了解ConstUnsafePointer
            let runArr = ((CTLineGetGlyphRuns(line) as [AnyObject]) as! [CTRunRef])
            let runCount = CFArrayGetCount(runArr)
            for i in 0..<runCount {
                let run = runArr[i]
                let charCount = CTRunGetGlyphCount(run)
                for j in 0..<charCount {// Glyph
                    let currentRange = CFRangeMake(j, 1)
                    var glyph: CGGlyph   = CGGlyph()
                    var position: CGPoint = CGPoint()
                    CTRunGetGlyphs(run, currentRange, &glyph)
                    CTRunGetPositions(run, currentRange, &position)
                    let currentPath = CTFontCreatePathForGlyph(font, glyph, nil)
                    var t = CGAffineTransformMakeTranslation(position.x, position.y);
                    CGPathAddPath(textPath, &t, currentPath)
                }
            }
            self.textProgressLayer      = CAShapeLayer()
            self.textProgressLayer.path = textPath
            let size =  CGPathGetBoundingBox(textPath).size
            self.textProgressLayer.frame = CGRect(x: (self.bounds.width - size.width) / 2, y: self.bounds.height - size.height - 8, width: size.width, height: size.height)
            // 翻转y
            self.textProgressLayer.geometryFlipped = true
            self.textProgressLayer.fillColor       = nil
            self.textProgressLayer.strokeColor     = highColor.CGColor
            self.textProgressLayer.lineWidth       = 1.0
            self.textProgressLayer.lineJoin        = kCALineJoinBevel
            self.textProgressLayer.strokeStart     = 0.0
            self.textProgressLayer.strokeEnd       = 0.0
            self.layer.addSublayer(self.textProgressLayer)
        }
    }
    private func setupTextGradientLayer() {
        if self.textgradientLayer == nil{
            self.textgradientLayer = CAGradientLayer()
            self.textgradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            self.textgradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            let colors = [highColor.CGColor, normalColor.CGColor, highColor.CGColor]
            textgradientLayer.colors = colors
            let locations = [0.25, 0.5, 0.75]
            self.textgradientLayer.locations = locations
            self.textgradientLayer.frame = CGRect(x: -self.bounds.width, y:self.bounds.height - 21 - 8, width: self.bounds.width * 2, height: 21)
            self.layer.addSublayer(self.textgradientLayer)
            
            // 设置mask
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.bounds.width , height: 21), false, 0)
            let style = NSMutableParagraphStyle()
            style.alignment = .Center
            
            let attr = [NSParagraphStyleAttributeName: style,NSFontAttributeName: UIFont(name: "HelveticaNeue-UltraLight", size: 21)!, NSForegroundColorAttributeName: highColor]
            UIGraphicsBeginImageContext(CGSize(width: self.bounds.width, height: 21))
            (self.gradientText as NSString).drawInRect(CGRect(x: 0,y: 0,width: self.bounds.width , height:21), withAttributes: attr)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let maskLayer = CALayer()
            maskLayer.frame = CGRect(x: self.bounds.width, y: 0, width: self.bounds.width, height: 21)
            maskLayer.contents = image.CGImage
            maskLayer.contentsGravity = kCAGravityCenter
            self.textgradientLayer.mask = maskLayer
            
            let gradientAnimation                 = CABasicAnimation(keyPath: "locations")
            gradientAnimation.fromValue           = [0.0, 0.0, 0.25]
            gradientAnimation.toValue             = [0.75, 1.0, 1.0]
            gradientAnimation.duration            = 2
            gradientAnimation.repeatCount         = Float.infinity
            gradientAnimation.removedOnCompletion = false
            gradientAnimation.fillMode            = kCAFillModeForwards
            
            self.textgradientLayer.addAnimation(gradientAnimation, forKey: nil)
        }
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: public
    func progress(value: CGFloat) {
        self.setupTextProgressLayer()
        if loading { return }
        if value > 1 {
            self.textProgressLayer.strokeEnd = 1.0
        } else if value < 0 {
            self.textProgressLayer.strokeEnd = 0.0
        }else {
            self.textProgressLayer.strokeEnd = value
        }
    }
    func enterLoading() {
        self.loading = true
        self.textProgressLayer.removeFromSuperlayer()
        self.setupTextGradientLayer()
    }
    func stop() {
        self.loading = false
        self.textgradientLayer.removeFromSuperlayer()
        self.textgradientLayer = nil
        self.layer.addSublayer(self.textProgressLayer)
    }

    
    
    var loading: Bool = false
}

