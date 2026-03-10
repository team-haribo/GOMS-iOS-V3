//
//  LoaderViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class LoaderViewController: BaseViewController {

    private let loadingView = UIImageView(image: .image.load.image)

    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimation()
    }

    public override func addView() {
        view.addSubview(loadingView)
    }

    public override func setLayout() {
        loadingView.snp.makeConstraints {
            $0.size.equalTo(80)
            $0.center.equalToSuperview()
        }
    }

    private func startAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        loadingView.layer.add(rotation, forKey: "spin")
    }

    private func stopAnimation() {
        loadingView.layer.removeAllAnimations()
    }
}
