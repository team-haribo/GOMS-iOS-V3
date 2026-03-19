//
//  MapReviewWriteView.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapReviewWriteView: UIView {
    
    // MARK: - UI Components
    
    private let backButtonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.isUserInteractionEnabled = false
    }
    
    public let backButton = UIButton()
    
    public let backButtonIcon = UIImageView().then {
        $0.image = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .color.gomsPrimary.color
        $0.contentMode = .scaleAspectFit
    }
    
    public let backButtonLabel = UILabel().then {
        $0.text = "돌아가기"
        $0.font = .suit(size: 18, weight: .medium)
        $0.textColor = .color.gomsPrimary.color
    }
    
    public let titleLabel = UILabel().then {
        $0.text = "후기 남기기"
        $0.font = .suit(size: 26, weight: .bold)
        $0.textColor = .color.mainText.color
    }
    
    private let placeInfoStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    private let nameCategoryStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .bottom
    }
    
    public let placeNameLabel = UILabel().then {
        $0.text = "짬뽕관 광주송정선운점"
        $0.font = .suit(size: 20, weight: .semibold)
        $0.textColor = .color.mainText.color
    }
    
    public let categoryLabel = UILabel().then {
        $0.text = "중식당"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub1.color
    }
    
    public let addressLabel = UILabel().then {
        $0.text = "광주 광산구 상무대로 277-1 1층"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }
    
    public let statsLabel = UILabel().then {
        $0.text = "학생 후기 4 | 추천 17"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }
    
    public let heartButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            $0.setImage(
                UIImage(named: "Hart", in: Bundle.module, compatibleWith: nil),
                for: .normal
            )
            $0.setImage(
                UIImage(systemName: "heart.fill", withConfiguration: config),
                for: .selected
            )
            $0.tintColor = .color.sub2.color
    }
    
    public let contentContainerView = UIView().then {
        $0.backgroundColor = .color.surface.color
        $0.layer.cornerRadius = 16
    }
    
    public let textView = UITextView().then {
        $0.backgroundColor = .clear
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.mainText.color
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    public let placeholderLabel = UILabel().then {
        $0.text = "가게 이용 후기를 남겨주세요!"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }
    
    public let limitLabel = UILabel().then {
        $0.text = "0/100"
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = .color.sub2.color
    }
    
    public let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = .suit(size: 18, weight: .semibold)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .color.button.color
        $0.setTitleColor(.color.sub2.color, for: .normal)
        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .color.background.color
        
        [backButtonIcon, backButtonLabel].forEach { backButtonStack.addArrangedSubview($0) }
        [placeNameLabel, categoryLabel].forEach { nameCategoryStack.addArrangedSubview($0) }
        [nameCategoryStack, addressLabel, statsLabel].forEach { placeInfoStack.addArrangedSubview($0) }
        
        [backButton, backButtonStack, titleLabel, placeInfoStack, heartButton, contentContainerView, limitLabel, nextButton].forEach {
            addSubview($0)
        }
        
        contentContainerView.addSubview(textView)
        contentContainerView.addSubview(placeholderLabel)
    }
    
    private func setupLayout() {
        backButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(18)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(100)
            $0.height.equalTo(30)
        }
        
        backButtonIcon.snp.makeConstraints { $0.size.equalTo(24) }
        
        backButtonStack.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.leading.equalTo(backButton)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
        }
        
        placeInfoStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
        }
        
        heartButton.snp.makeConstraints {
            $0.centerY.equalTo(placeNameLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(28)
        }
        
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(placeInfoStack.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(160)
        }
        
        textView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        limitLabel.snp.makeConstraints {
            $0.top.equalTo(contentContainerView.snp.bottom).offset(8)
            $0.trailing.equalTo(contentContainerView)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
    }
    
    public func updateButtonState(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.backgroundColor = isEnabled ? .color.gomsPrimary.color : .color.button.color
        nextButton.setTitleColor(isEnabled ? .white : .color.sub2.color, for: .normal)
    }
}
