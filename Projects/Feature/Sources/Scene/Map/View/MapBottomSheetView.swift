//
//  MapBottomSheetView.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapBottomSheetView: UIView {
    public var onCardTapped: (() -> Void)?
    private var recommendedCount: Int = 2
    private var reviewCount: Int = 3
    
    private let pointColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
    
    private let handleView = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0.2)
        $0.layer.cornerRadius = 2.5
    }
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addView()
        setLayout()
        renderUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        self.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        self.layer.cornerRadius = 12
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func addView() {
        addSubview(handleView)
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
    }
    
    private func setLayout() {
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40); $0.height.equalTo(5)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentStackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    private func renderUI() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        addSpacer(32)
        contentStackView.addArrangedSubview(createTitleLabel("최근 인기 장소 🔥", fontSize: 22))
        addSpacer(16)

        for _ in 0..<3 {
            addCard(type: .popular, isFavorite: false)
            addSpacer(12)
        }

        addSpacer(28)
        contentStackView.addArrangedSubview(createTitleLabel("내 활동", fontSize: 22))
        addSpacer(16)

        if recommendedCount > 0 {
            contentStackView.addArrangedSubview(createSubTitleLabel(title: "추천한 가게", count: recommendedCount, unit: "곳", fontSize: 18))
            addSpacer(16)
            for _ in 0..<recommendedCount {
                addCard(type: .recommended, isFavorite: true)
                addSpacer(12)
            }
        }

        if reviewCount > 0 {
            addSpacer(8)
            contentStackView.addArrangedSubview(createSubTitleLabel(title: "작성한 후기", count: reviewCount, unit: "건", fontSize: 18))
            addSpacer(16)
            for _ in 0..<reviewCount {
                addCard(type: .reviewed, isFavorite: false)
                addSpacer(12)
            }
        }
        addSpacer(40)
    }

    private func addCard(type: MapCardType, isFavorite: Bool) {
        let card = MapCardView(type: type)
        
        if let actionButton = card.subviews.first(where: { $0 is UIButton }) as? UIButton {
            if type == .reviewed {
                actionButton.tintColor = .systemRed
            } else {
                actionButton.isSelected = isFavorite
                actionButton.tintColor = isFavorite ? pointColor : .white.withAlphaComponent(0.3)
                actionButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
            }
        }
        
        card.subviews.forEach { subview in
            if let stack = subview as? UIStackView {
                stack.spacing = 4
                if let titleLabel = stack.arrangedSubviews.first as? UILabel {
                    titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
                }
                stack.arrangedSubviews.filter({ $0 is UILabel }).forEach {
                    if let label = $0 as? UILabel, label.font.pointSize < 20 {
                        label.font = .systemFont(ofSize: 16, weight: .medium)
                    }
                }
                stack.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(16)
                    $0.bottom.equalToSuperview().offset(-16)
                    $0.leading.equalToSuperview().offset(16)
                    $0.trailing.lessThanOrEqualToSuperview().offset(-50)
                }
            }
        }
        
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
        
        contentStackView.addArrangedSubview(card)
        card.snp.makeConstraints {
            $0.height.equalTo(105)
        }
    }

    @objc private func heartButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? pointColor : .white.withAlphaComponent(0.3)
    }

    @objc private func didTapCard() { onCardTapped?() }

    private func createTitleLabel(_ text: String, fontSize: CGFloat) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.textColor = .white
            $0.font = .systemFont(ofSize: fontSize, weight: .bold)
        }
    }

    private func createSubTitleLabel(title: String, count: Int, unit: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        let countText = "\(count)"
        let fullText = "\(title) \(countText)\(unit)"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: fullText.count))
        let countRange = (fullText as NSString).range(of: countText)
        attributedString.addAttribute(.foregroundColor, value: pointColor, range: countRange)
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: fontSize, weight: .semibold)
        return label
    }

    private func addSpacer(_ height: CGFloat) {
        let spacer = UIView()
        contentStackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { $0.height.equalTo(height) }
    }
}
