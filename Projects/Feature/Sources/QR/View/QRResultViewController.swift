//
//  QRResultViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

final class QRResultViewController: BaseViewController {
    
    // MARK: Propertices
    private let resultType: QRResultType
    
    init(resultType: QRResultType) {
        self.resultType = resultType
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private let image = UIImageView()
    
    private let mainLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 24, weight: .bold)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .color.gomsSecondary.color
        $0.font = .suit(size: 16, weight: .regular)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.setLineSpacing(spacing: 3)
    }
    
    private lazy var confirmButton = GOMSButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "홈으로 돌아가기").then {
        $0.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    // MARK: - Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    

    
    // MARK: - Add View
    override func addView() {
        [image, mainLabel, descriptionLabel, confirmButton].forEach { view.addSubview($0) }
    }
    
    // MARK: - Layout
    override func setLayout() {
        image.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(150)
            $0.top.equalTo(bounds.height * 0.3)
        }
        
        mainLabel.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(image.snp.bottom).offset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mainLabel.snp.bottom).offset(4)
            $0.height.equalTo(56)
        }
        
        confirmButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(48)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-bounds.height * 0.07)
        }
    }
    
    // MARK: - Method
    private func setupUI() {
        image.image = resultType.image
        mainLabel.text = resultType.mainText
        descriptionLabel.text = resultType.descriptionText
    }

    // MARK: - Selector
    @objc func confirmButtonTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
