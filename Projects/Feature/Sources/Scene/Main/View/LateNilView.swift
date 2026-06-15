//
//  LateNilView.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

final class LateNilView: UIView {

    // MARK: - Properties
    
    private let icon = UIImageView().then {
        $0.image = UIImage(
            named: "Fire",
            in: Bundle.module,
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)

        $0.tintColor = .color.sub2.color
        $0.contentMode = .scaleAspectFit
    }
    
    private let mainLabel = UILabel().then {
        $0.text = "이번 주 지각자가 없어요! 축하해요!"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .semibold)
    }

    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 6
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addView() {
        [icon, mainLabel].forEach { stackView.addArrangedSubview($0) }
        self.addSubview(stackView)
    }

    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview()  
        }

        icon.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
}
