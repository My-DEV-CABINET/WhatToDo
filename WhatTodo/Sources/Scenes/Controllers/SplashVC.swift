//
//  SplashVC.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/14/24.
//

/// Lottie
import Lottie

/// Apple
import UIKit

final class SplashVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var baseView: UIView!

    private var animationView: LottieAnimationView?
}

// MARK: - View Life Cycle

extension SplashVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension SplashVC {
    private func setupUI() {
        animationView = .init(name: "flash")

        // animationView가 nil인지 확인
        guard let animationView = animationView else {
            print("#### Error: animationView is nil.")
            return
        }

        animationView.frame = baseView.bounds
        animationView.center = baseView.center
        animationView.contentMode = .scaleAspectFit

        baseView.addSubview(animationView)

        animationView.loopMode = .loop
        animationView.play()
    }
}
