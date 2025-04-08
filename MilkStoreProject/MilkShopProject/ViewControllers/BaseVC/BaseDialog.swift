//
//  BaseDialog.swift

import UIKit

enum PositionDialog{
    case top
    case center
    case bottom
}

@objc protocol BaseDialogDelegate: AnyObject {
    @objc optional func setUpDialog()
    @objc optional func willShowDialog()
    @objc optional func didShowDialog()
    @objc optional func willHideDialog()
    @objc optional func didHideDialog()
}

class BaseDialog: UIViewController {
    
    // MARK: Properties
    private var dialogAlert: UIView?
    weak var delegate: BaseDialogDelegate?
    
    var cancelable: Bool = false {
        didSet {
            if self.cancelable {
                let buttonDismiss = UIButton(frame: CGRect(x: self.view.bounds.x, y: self.view.bounds.y, width: 50000, height: 50000))
                self.view.insertSubview(buttonDismiss, belowSubview: self.dialogAlert ?? UIView())
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                buttonDismiss.addGestureRecognizer(tap)
            }
        }
    }
    
    var blurLayout: Bool = false {
        didSet {
            if self.blurLayout{
                self.view.backgroundColor = .clear
                self.view.backgroundColor = .black.withAlphaComponent(0.5)
            }
        }
    }
    
    // MARK: Init
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Functions
    func setUpDefaultAlert(_ dialogAlert: UIView, position: PositionDialog = .center) {
        self.dialogAlert = dialogAlert
        self.view.alpha = 0
        self.dialogAlert?.alpha = 0
        self.dialogAlert?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        switch position {
        case .top:
            self.dialogAlert?.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        case .center:
            self.dialogAlert?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        case .bottom:
            self.dialogAlert?.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        
        self.delegate?.setUpDialog?()
    }
    
    // Appear Dialog
    func appear(sender: UIViewController, duration: TimeInterval = 0.2, delay: TimeInterval = 0.0) {
        sender.present(self, animated: false) {
            self.showAlert(duration: duration, delay: delay)
        }
    }
    
    func showAlert(duration: TimeInterval = 0.2, delay: TimeInterval = 0.0) {
        self.delegate?.willShowDialog?()
        UIView.animate(withDuration: duration, delay: delay, animations: {
            self.view.alpha = 1
            self.dialogAlert?.alpha = 1
        }, completion: { _ in
            self.delegate?.didShowDialog?()
        })
    }
    
    // Dismiss Dialog
    func hideAlert(duration: TimeInterval = 0.2, delay: TimeInterval = 0.0) {
        self.delegate?.willHideDialog?()
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut) {
            self.view.alpha = 0
            self.dialogAlert?.alpha = 0
        } completion: { _ in
            self.dismiss(animated: true)
            self.removeFromParent()
            self.delegate?.didHideDialog?()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.hideAlert()
    }
}


