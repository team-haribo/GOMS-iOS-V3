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
    
    private let primaryColor = UIColor(red: 255/255, green: 110/255, blue: 15/255, alpha: 1)
    private let deleteColor = UIColor.systemRed
    
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
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
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

        addSpacer(36)
        let popularTitle = createTitleLabel("최근 인기 장소 🔥", fontSize: 20)
        contentStackView.addArrangedSubview(popularTitle)
        popularTitle.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        addSpacer(16)

        for _ in 0..<3 {
            addCard(type: .popular, isFavorite: false)
            addSpacer(12)
        }

        addSpacer(4)
        let myActivityTitle = createTitleLabel("내 활동", fontSize: 20)
        contentStackView.addArrangedSubview(myActivityTitle)
        myActivityTitle.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        addSpacer(16)

        if recommendedCount > 0 {
            let recommendedLabel = createSubTitleLabel(title: "추천한 가게", count: recommendedCount, unit: "곳", fontSize: 18)
            contentStackView.addArrangedSubview(recommendedLabel)
            recommendedLabel.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            addSpacer(16)
            for _ in 0..<recommendedCount {
                addCard(type: .recommended, isFavorite: true)
                addSpacer(16)
            }
        }

        if reviewCount > 0 {
            let reviewLabel = createSubTitleLabel(title: "작성한 후기", count: reviewCount, unit: "건", fontSize: 18)
            contentStackView.addArrangedSubview(reviewLabel)
            reviewLabel.snp.makeConstraints {
                $0.height.equalTo(24)
            }
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
                actionButton.tintColor = deleteColor
            } else {
                actionButton.isSelected = isFavorite
                actionButton.tintColor = isFavorite ? primaryColor : .white.withAlphaComponent(0.3)
                actionButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
            }
        }
        
        card.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        card.addGestureRecognizer(tap)
        
        contentStackView.addArrangedSubview(card)
        card.snp.makeConstraints {
            $0.height.equalTo(92)
        }
    }

    @objc private func heartButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? primaryColor : .white.withAlphaComponent(0.3)
    }

    @objc private func didTapCard() { onCardTapped?() }

    private func createTitleLabel(_ text: String, fontSize: CGFloat) -> UILabel {
        return UILabel().then {
            $0.text = text; $0.textColor = .white
            $0.font = .systemFont(ofSize: fontSize, weight: .semibold)
        }
    }

    private func createSubTitleLabel(title: String, count: Int, unit: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        let countText = "\(count)"
        let fullText = "\(title) \(countText)\(unit)"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: fullText.count))
        
        let countRange = (fullText as NSString).range(of: countText)
        attributedString.addAttribute(.foregroundColor, value: primaryColor, range: countRange)
        
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
