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
    
    private let pointColor = UIColor.color.gomsPrimary.color
    
    private let handleView = UIView().then {
        $0.backgroundColor = UIColor.color.gomsDivider.color
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
        self.backgroundColor = UIColor.color.surface.color
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
    
    private func createPopularTitleView() -> UIView {
        let titleLabel = createTitleLabel("최근 인기 장소", fontSize: 22)
        let fireImageView = UIImageView().then {
            $0.image = UIImage(named: "Fire", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.color.gomsNegative.color
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { $0.size.equalTo(24) }
        }
        let stack = UIStackView(arrangedSubviews: [titleLabel, fireImageView]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 6.77
        }
        let container = UIView()
        container.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        return container
    }

    private func renderUI() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addSpacer(32)
        contentStackView.addArrangedSubview(createPopularTitleView())
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
        
        // 1. 카드 배경색 설정
        card.backgroundColor = UIColor.color.gomsCardBackgroundColor.color
        card.layer.cornerRadius = 12
        
        // 2. 카드 그림자 추가 (디자인과 비슷하게)
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.layer.masksToBounds = false

        // 3. 버튼 설정
        if let actionButton = card.subviews.first(where: { $0 is UIButton }) as? UIButton {
            if type == .reviewed {
                actionButton.tintColor = UIColor.color.gomsNegative.color
            } else {
                actionButton.isSelected = isFavorite
                actionButton.tintColor = isFavorite ? pointColor : UIColor.color.gomsDivider.color
                actionButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
            }
        }
        
        // 4. 🔥 핵심 해결책: 카드 내부의 모든 라벨을 재귀적으로 탐색하여 색상 강제 적용
        func applyLabelColors(in view: UIView) {
            for subview in view.subviews {
                if let label = subview as? UILabel {
                    // 텍스트 내용이나 폰트 굵기를 기준으로 장소 제목 구분
                    if label.font.pointSize >= 15 || label.font == .systemFont(ofSize: 16, weight: .bold) {
                        label.textColor = UIColor.color.mainText.color
                    } else {
                        label.textColor = UIColor.color.sub1.color
                    }
                } else {
                    // 라벨이 아닌 경우 더 깊게 들어감
                    applyLabelColors(in: subview)
                }
            }
        }
        
        applyLabelColors(in: card)
        
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
        
        contentStackView.addArrangedSubview(card)
        card.snp.makeConstraints { $0.height.equalTo(105) }
    }

    @objc private func heartButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.tintColor = sender.isSelected ? pointColor : UIColor.color.gomsDivider.color
    }

    @objc private func didTapCard() { onCardTapped?() }

    private func createTitleLabel(_ text: String, fontSize: CGFloat) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.textColor = UIColor.color.mainText.color
            $0.font = .systemFont(ofSize: fontSize, weight: .bold)
        }
    }

    private func createSubTitleLabel(title: String, count: Int, unit: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        let countText = "\(count)"
        let fullText = "\(title) \(countText)\(unit)"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.mainText.color, range: NSRange(location: 0, length: fullText.count))
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
