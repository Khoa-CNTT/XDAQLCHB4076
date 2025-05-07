//
//  UIView+.swift
//  AIPhotoProject

import Foundation
import UIKit

extension UIView{
    func roundCorners1(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         layer.mask = mask
     }
    
    func show() {
        DispatchQueue.main.async {
            self.isHidden = false
        }
    }

//    func hide() {
//        DispatchQueue.main.async {
//            self.isHidden = true
//        }
//    }
    
    func makeCorner(_ radius: CGFloat? = nil) {
        self.layoutIfNeeded()
        self.layer.cornerRadius = radius ?? width > height ? height/2 : width/2
        self.layer.masksToBounds = true
    }
    
    func makeBorder(radius: CGFloat, width: CGFloat = 0, color: CGColor = UIColor.clear.cgColor, corners: UIRectCorner = .allCorners) {
        if corners == .allCorners {
            self.layer.cornerRadius = radius
            self.layer.borderWidth = width
            self.layer.borderColor = color
            self.layer.masksToBounds = true
        } else {
            let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = bounds
            shapeLayer.path = maskPath.cgPath
            shapeLayer.borderColor = color
            shapeLayer.borderWidth = width
            layer.mask = shapeLayer
        }
    }
    
    public func makeShadow(opacity: Float = 1, radius: CGFloat = 10, height: CGFloat = 5, color: UIColor = .gray, bottom: Bool = true, all: Bool = false) {
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        
        if all {
            self.layer.shadowOffset = .zero
        } else {
            let offset = bottom ? CGSize(width: 0, height: height): CGSize(width: height, height: 0)
            self.layer.shadowOffset = offset
        }
        
        self.layer.masksToBounds = false
    }

    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
    
    func slideDownHideBottom(_ duration: CGFloat){
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
            self.center.y += (UIScreen.main.bounds.height / 3.2 + self.bounds.height / 3.2)
            self.layoutIfNeeded()
        }, completion: {(_ completed: Bool) -> Void in
            //self.isHidden = true
        })
    }
    //
    func slideUpShowBottom(_ duration: CGFloat){
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
            self.center.y -= (UIScreen.main.bounds.height / 3.2 + self.bounds.height / 3.2)
            self.layoutIfNeeded()
        }, completion: nil)
        //self.isHidden = false
    }
    
    //gradient
    func applyGradient(isVertical: Bool, colorArray: [UIColor]) {
        layer.sublayers?.filter({ $0 is CAGradientLayer }).forEach({ $0.removeFromSuperlayer() })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isVertical {
            //top to bottom
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientBackground() {
        let colorTop =   UIColor(red: 0, green: 0.635, blue: 1, alpha: 1).cgColor
        let colorBottom =  UIColor(red: 0, green: 0.535, blue: 0.842, alpha: 1).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
                
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func setGradientBackgroundButton() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexString: "0A15DB")!.cgColor,UIColor(hexString: "20F8FA")!.cgColor]
//        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func gradientLeftToRight(startColor: UIColor,middle: UIColor, endColor: UIColor){
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.frame.size
        gradientLayer.colors = [startColor.cgColor, middle.cgColor,endColor.cgColor]
        // Left to right
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradientLayer, at: 0)
      }
    
    func setGradientBackgroundButton(color: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = color
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.bounds
//        gradientLayer.cornerRadius = 24
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func addGradientBorder(colors: [CGColor], cornerRadius: CGFloat = 10, borderWidthColor: CGFloat = 3) {
            self.layoutIfNeeded()
            let gradient = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.colors = colors
            
            let shape = CAShapeLayer()
            shape.lineWidth = borderWidthColor
            shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
            
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            self.layer.cornerRadius = cornerRadius
            self.layer.addSublayer(gradient)
    }
    
    func removeSuperGradient() {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }
    
    //làm animation ánh sáng chạy
    var snapshot1: UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)

        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        return image
    }
    
    func flash() {
        // Take as snapshot of the button and render as a template
        let snapshot = self.snapshot1?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: snapshot)
        // Add it image view and render close to white
        imageView.tintColor = UIColor(white: 1, alpha: 1.0)
        guard let image = imageView.snapshot1  else { return }
        let width = image.size.width
        let height = image.size.height
        // Create CALayer and add light content to it
        let shineLayer = CALayer()
        shineLayer.contents = image.cgImage
        shineLayer.frame = bounds

        // create CAGradientLayer that will act as mask clear = not shown, opaque = rendered
        // Adjust gradient to increase width and angle of highlight
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor.clear.cgColor,
                                UIColor.black.cgColor,
                                UIColor.clear.cgColor,
                                UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.35, 0.50, 0.65, 0.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)

        gradientLayer.frame = CGRect(x: CGFloat(Int(-width)), y: 0, width: width, height: height)
        // Create CA animation that will move mask from outside bounds left to outside bounds right
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.byValue = width * 2
        // How long it takes for glare to move across button
        animation.duration = 3
        // Repeat forever
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        layer.addSublayer(shineLayer)
        shineLayer.mask = gradientLayer

        // Add animation
        gradientLayer.add(animation, forKey: "shine")
    }

    func stopFlash() {
        // Search all sublayer masks for "shine" animation and remove
        layer.sublayers?.forEach {
            $0.mask?.removeAnimation(forKey: "shine")
        }
    }
    
    //__________________________________________
    var snapshot: UIImage {
        UIGraphicsImageRenderer(bounds: bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    func takeSnapshotOfView() -> UIImage? {

        let size = CGSize(width: frame.size.width, height: frame.size.height)
        let rect = CGRect.init(origin: .init(x: 0, y: 0), size: frame.size)


        UIGraphicsBeginImageContext(size)
        drawHierarchy(in: rect, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        guard let imageData = image?.pngData() else {
           return nil
        }

        return UIImage.init(data: imageData)
    }
    
    func takeScreenshot() -> UIImage {

            // Begin context
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

            // Draw view in that context
            drawHierarchy(in: self.bounds, afterScreenUpdates: true)

            // And finally, get image
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if (image != nil)
            {
                return image!
            }
            return UIImage()
        }
    
    func screenshot() -> UIImage {
      return UIGraphicsImageRenderer(size: bounds.size).image { _ in
        drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
      }
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImageFromMyView!
    }
    
    func setBackgroundImage(img: UIImage){
        
        UIGraphicsBeginImageContext(self.frame.size)
        img.draw(in: self.bounds)
        let patternImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: patternImage)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        func roundCorners(corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
        layer.shadowPath = UIBezierPath.init(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    func makeShadowMinh(opacity: Float = 1, radius: CGFloat = 10, height: CGFloat = 5, color: UIColor = .gray, bottom: Bool = true, all: Bool = false) {
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        if all {
          self.layer.shadowOffset = .zero
        } else {
          let offset = bottom ? CGSize(width: 0, height: height): CGSize(width: height, height: 0)
          self.layer.shadowOffset = offset
        }
        self.layer.masksToBounds = false
      }
    
    // add drop shadow effect
    func addDropShadow(scale: Bool = true, cornerRadius: CGFloat ) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 1.5
        //layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
//    func addShadow(alpha: Float, isTop: Bool) {
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = alpha
//        layer.shadowOffset = CGSize(width: 0, height: isTop ? -1 : 1.5 )
//        layer.shadowRadius = 1
//    }
    
    func addShadow(alpha: Float, isTop: Bool, color: UIColor ) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: 0, height: isTop ? -1 : 5 )
        layer.shadowRadius = 3
    }
    
    static var loadNib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }
    
    func contentFromXib() -> UIView? {
        guard let contentView = type(of: self).loadNib.instantiate(withOwner: self, options: nil).last as? UIView else {
            return nil
        }
        
        contentView.frame = self.bounds
        self.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        ])
        
        return contentView
    }
    
    @IBInspectable var kBorderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
//
    @IBInspectable var kBorderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var kCornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var kCircle: Bool {
        set {
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.bounds.height/2
                self.layer.masksToBounds = true
            }
        }
        get {
            return layer.masksToBounds
        }
    }
    
    @IBInspectable var kShadowColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
//
    @IBInspectable var kShadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var kShadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var kShadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    
    @IBInspectable var kShadowMasksToBounds: Bool {
        set {
            layer.masksToBounds = newValue
        }
        get {
            return layer.masksToBounds
        }
    }
    
    @IBInspectable var shouldRasterize : Bool {
        set {
            self.layer.shouldRasterize = newValue
        }

        get {
            return self.layer.shouldRasterize
        }
    }
    
    func removeAll() {
        for subUIView in self.subviews as [UIView] {
            subUIView.removeFromSuperview()
        }
    }
    
    public var x: CGFloat {
        get { return self.frame.x }
        set { self.frame.x = newValue }
    }
    
    public var y: CGFloat {
        get { return self.frame.y }
        set { self.frame.y = newValue }
    }
    
    public var width: CGFloat {
        get { return self.frame.width }
        set { self.frame.size.width = newValue }
    }
    
    public var height: CGFloat {
        get { return self.frame.height }
        set { self.frame.size.height = newValue }
    }
    
    public var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }
    
    public var origin: CGPoint {
        get { return self.frame.origin }
        set { self.frame.origin = newValue }
    }
    
    public var addSize: CGFloat {
        get { return 0 }
        set {
            width += newValue
            height += newValue
        }
    }
    
    @nonobjc func addSubview(firstView: UIView, secondView: UIView) {
      [firstView, secondView].forEach { addSubview($0) }
    }
}
// Getting frame's components
public extension CGRect {
    
    var x: CGFloat {
        get { return self.origin.x }
        set { self.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return self.origin.y }
        set { self.origin.y = newValue }
    }
    
    var doubleSize: CGSize {
        get { return CGSize(width: size.width * 2, height: size.height * 2) }
        set { self.size = newValue }
    }
    
    var addSize: CGFloat {
        get { return 0 }
        set {
            size.width += newValue
            size.height += newValue
        }
    }
    
    var subOrigin: CGFloat {
        get { return 0 }
        set {
            x -= newValue
            y -= newValue
        }
    }
}

extension UIView {
    func findSubview(withTag tag: Int) -> UIView? {
        for subview in self.subviews {
            if subview.tag == tag {
                return subview
            }
        }
        return nil
    }
}

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
