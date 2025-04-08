//
//  PopUpSuccessView.swift
//  aiimagegeneration
//
//  Created by IC CREATORY  (FOUNDER) on 19/09/2023.
//

import UIKit
import Lottie

final class PopUpSuccessSignUpView: UIView {
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var blurView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupAnimationView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupAnimationView()
    }
    
    override func layoutSubviews() {
        DispatchQueue.main.async {
            self.loginButton.layerCornerRadius = self.loginButton.bounds.height / 2
            self.cancelButton.layerCornerRadius = self.cancelButton.bounds.height / 2
        }
    }
    
    func setupView() {
        Bundle.main.loadNibNamed("PopUpSuccessSignUpView", owner: self, options: nil)
//        contentView.setGradientBackground(colors: [UIColor(hexString: "FBF6EC").cgColor, UIColor(hexString: "DCC296").cgColor])
        addSubview(mainView)
        mainView.frame = bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setupAnimationView() {
        animationView.loopMode = .loop
        animationView.play()
        animationView.contentMode = .scaleAspectFit
    }

    private func removeAnimationView() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func didClickLoginButton(_ sender: UIButton) {
        removeAnimationView()
        AppDelegate.setRoot(LoginVC())
    }
    
    @IBAction func didClickCancelButton(_ sender: UIButton) {
        removeAnimationView()
    }
}
