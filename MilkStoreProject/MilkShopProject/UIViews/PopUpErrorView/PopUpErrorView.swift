//
//  PopUpErrorView.swift
//  aiimagegeneration
//
//  Created by IC CREATORY  (FOUNDER) on 19/09/2023.
//

import UIKit
import FirebaseAuth
import Lottie

final class PopUpErrorView: UIView {
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var blurView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!
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
            self.tryAgainButton.layerCornerRadius = self.tryAgainButton.bounds.height / 2
            self.cancelButton.layerCornerRadius = self.cancelButton.bounds.height / 2
        }
    }
    
    func setupView() {
        Bundle.main.loadNibNamed("PopUpErrorView", owner: self, options: nil)
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
    
    @IBAction func didClickTryAgainButton(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            AppDelegate.setRoot(RegisterVC())
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
        removeAnimationView()
    }
    
    @IBAction func didClickCancelButton(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            AppDelegate.setRoot(RegisterVC())
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
        removeAnimationView()
    }
}
