//
//  MapRouteSelectionView.swift
//  Feature
//
//  Created by 김민선 on 2/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class PathRecommendationCard: UIView {
    private let titleLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    private let arrowIcon = UIImageView().then {
        $0.image = UIImage(named: "rightArrow", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .color.sub1.color
    }
    private let timeLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    private let infoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .regular)
    }
    public init(title: String, time: String, info: String) {
        super.init(frame: .zero)
        self.backgroundColor = .color.surface.color
        self.layer.cornerRadius = 12
        titleLabel.text = title
        timeLabel.text = time
        infoLabel.text = info
        [titleLabel, arrowIcon, timeLabel, infoLabel].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview().offset(16) }
        arrowIcon.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(2)
            $0.size.equalTo(12)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }
        infoLabel.snp.makeConstraints { $0.bottom.leading.equalToSuperview().inset(16) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

public final class MapRouteSelectionView: UIView {
    
    private let locations = ["내 위치", "학교"]
    private var destinationName: String = "짬뽕관 광주송정선운점"
    
    private let containerView = UIView().then {
        $0.backgroundColor = .color.surface.color
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    public let backButton = UIButton().then {
        $0.setImage(UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub1.color
    }

    private let startTitleLabel = UILabel().then {
        $0.text = "출발"
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .medium)
    }

    public let startDropdownButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .color.button.color
        
        // 초기 텍스트: "출발 위치를 선택해주세요", 색상: sub2
        var titleAttr = AttributedString("출발 위치를 선택해주세요")
        titleAttr.font = .suit(size: 17, weight: .medium)
        titleAttr.foregroundColor = .color.sub2.color
        config.attributedTitle = titleAttr
        
        config.image = UIImage(named: "Down directional", in: Bundle.module, compatibleWith: nil)
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        config.cornerStyle = .fixed
        config.background.cornerRadius = 8
        
        $0.configuration = config
        $0.contentHorizontalAlignment = .fill
    }
    
    private let selectionBox = UIView().then {
        $0.backgroundColor = .color.button.color
        $0.layer.cornerRadius = 8
        $0.isHidden = true
        $0.clipsToBounds = true
    }

    private lazy var myLocationBtn = UIButton().then {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString(locations[0])
        titleAttr.font = .suit(size: 17, weight: .medium)
        titleAttr.foregroundColor = .color.mainText.color
        config.attributedTitle = titleAttr
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
    }

    private lazy var schoolLocationBtn = UIButton().then {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString(locations[1])
        titleAttr.font = .suit(size: 17, weight: .medium)
        titleAttr.foregroundColor = .color.mainText.color
        config.attributedTitle = titleAttr
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
    }

    private let line = UIView().then {
        $0.backgroundColor = .color.sub2.color.withAlphaComponent(0.3)
    }

    private let endTitleLabel = UILabel().then {
        $0.text = "도착"
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .medium)
    }

    public lazy var endLocationLabel = UILabel().then {
        $0.text = "   \(destinationName)"
        $0.textColor = .color.mainText.color // 도착지도 mainText로 변경
        $0.font = .suit(size: 17, weight: .medium)
        $0.backgroundColor = .color.button.color
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    public let reverseButton = UIButton().then {
        $0.setImage(UIImage(named: "Shift", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.gomsPrimary.color
    }

    public let recommendationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
        addCards()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        addSubview(containerView)
        [startTitleLabel, backButton, startDropdownButton, endTitleLabel, endLocationLabel, reverseButton, selectionBox].forEach {
            containerView.addSubview($0)
        }
        [myLocationBtn, schoolLocationBtn, line].forEach { selectionBox.addSubview($0) }
        addSubview(recommendationStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(endLocationLabel.snp.bottom).offset(24)
        }
        
        startTitleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(-30)
            $0.leading.equalToSuperview().offset(52)
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(startTitleLabel)
            $0.trailing.equalTo(startTitleLabel.snp.leading).offset(-4)
            $0.size.equalTo(22)
        }

        startDropdownButton.snp.makeConstraints {
            $0.top.equalTo(startTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(52)
        }

        selectionBox.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(startDropdownButton)
            $0.height.equalTo(104)
        }

        myLocationBtn.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }

        line.snp.makeConstraints {
            $0.centerY.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        schoolLocationBtn.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        
        reverseButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(startDropdownButton.snp.bottom).offset(6)
            $0.size.equalTo(24)
        }

        endTitleLabel.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(10)
            $0.leading.equalTo(startTitleLabel)
        }
        
        endLocationLabel.snp.makeConstraints {
            $0.top.equalTo(endTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(52)
        }

        recommendationStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(110)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(106)
            $0.width.equalTo(192 * 2 + 12)
        }
    }

    private func setupActions() {
        startDropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)
        myLocationBtn.addTarget(self, action: #selector(didSelectOption), for: .touchUpInside)
        schoolLocationBtn.addTarget(self, action: #selector(didSelectOption), for: .touchUpInside)
    }

    @objc private func didTapDropdown() {
        selectionBox.isHidden.toggle()
        containerView.bringSubviewToFront(selectionBox)
    }

    @objc private func didSelectOption(_ sender: UIButton) {
        guard let title = sender.configuration?.attributedTitle else { return }
        let plainTitle = String(title.characters)
        
        var config = startDropdownButton.configuration
        var titleAttr = AttributedString(plainTitle)
        titleAttr.font = .suit(size: 17, weight: .medium)
        titleAttr.foregroundColor = .color.mainText.color // 선택 시 색상 변경
        config?.attributedTitle = titleAttr
        startDropdownButton.configuration = config
        
        selectionBox.isHidden = true
    }

    private func addCards() {
        let card1 = PathRecommendationCard(title: "추천", time: "8분", info: "339m | 25kcal")
        let card2 = PathRecommendationCard(title: "큰길 우선", time: "10분", info: "450m | 30kcal")
        [card1, card2].forEach { recommendationStackView.addArrangedSubview($0) }
    }
}
