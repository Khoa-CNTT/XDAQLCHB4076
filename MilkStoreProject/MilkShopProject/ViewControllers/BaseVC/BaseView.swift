//  BaseView.swift
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    private func commonInit() {
        guard Bundle.main.path(forResource: className, ofType: "nib") != nil else {
            // file not exists
            setupUI()
            return
        }
        
        guard let content = Bundle.main.loadNibNamed(className, owner: self, options: nil)?.first as? UIView else {
            return
        }
        content.frame = bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(content)
        setupUI()
    }

    internal func setupUI() { }
    internal func setupLayout() { }

    deinit {
        print("++++++++++++++++++++++++\(String(describing: self))")
    }
}
extension NSObject {
    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}
