//
//  PopUpSuccesssSignInVC.swift
//  aiimagegeneration
//
//  Created by IC CREATORY  (FOUNDER) on 20/09/2023.
//

import UIKit
import Lottie

final class PopUpSuccesssSignInVC: UIView {
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var blurView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var mainView: UIView!
    
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
    
    func setupView() {
        Bundle.main.loadNibNamed("PopUpSuccesssSignInVC", owner: self, options: nil)
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
}
