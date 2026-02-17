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
    
    // 데이터 개수 (이 숫자만큼 카드가 생성됩니다)
    private var recommendedCount: Int = 2
    private var reviewCount: Int = 3
    
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
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGesture()
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

    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newY = self.frame.minY + translation.y
        
        if newY >= 100 {
            self.frame.origin.y = newY
            gesture.setTranslation(.zero, in: self)
        }
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: self).y
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
                if velocity < -500 || newY < 350 {
                    self.frame.origin.y = 100
                } else {
                    self.frame.origin.y = 600
                }
            }, completion: nil)
        }
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
            $0.width.equalTo(40)
            $0.height.equalTo(5)
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

        // 1. 최근 인기 장소 (3개)
        let popularTitle = createTitleLabel("최근 인기 장소 🔥", fontSize: 20)
        contentStackView.addArrangedSubview(popularTitle)
        popularTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(37)
            $0.leading.equalToSuperview().offset(22)
            $0.height.equalTo(24)
        }
        addSpacer(16)

        // 경고 해결: 사용하지 않는 인덱스 i를 _로 대체
        for _ in 0..<3 {
            let card = createCard(type: .popular)
            contentStackView.addArrangedSubview(card)
            card.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.height.equalTo(93)
            }
            addSpacer(12)
        }

        addSpacer(24)

        // 2. 내 활동 섹션
        let myActivityTitle = createTitleLabel("내 활동", fontSize: 20)
        contentStackView.addArrangedSubview(myActivityTitle)
        myActivityTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.height.equalTo(24)
        }
        addSpacer(12)

        // 추천한 가게 (recommendedCount만큼 생성)
        if recommendedCount > 0 {
            let recommendedLabel = createSubTitleLabel(title: "추천한 가게", count: recommendedCount, unit: "곳", fontSize: 18)
            contentStackView.addArrangedSubview(recommendedLabel)
            recommendedLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(22)
                $0.height.equalTo(22)
            }
            addSpacer(12)

            for _ in 0..<recommendedCount {
                let card = createCard(type: .recommended)
                contentStackView.addArrangedSubview(card)
                card.snp.makeConstraints {
                    $0.leading.trailing.equalToSuperview().inset(24)
                    $0.height.equalTo(93)
                }
                addSpacer(12)
            }
        }

        // 작성한 후기 (reviewCount만큼 생성)
        if reviewCount > 0 {
            addSpacer(12)
            let reviewLabel = createSubTitleLabel(title: "작성한 후기", count: reviewCount, unit: "건", fontSize: 18)
            contentStackView.addArrangedSubview(reviewLabel)
            reviewLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(22)
                $0.height.equalTo(22)
            }
            addSpacer(12)

            for _ in 0..<reviewCount {
                let card = createCard(type: .reviewed)
                contentStackView.addArrangedSubview(card)
                card.snp.makeConstraints {
                    $0.leading.trailing.equalToSuperview().inset(24)
                    $0.height.equalTo(93)
                }
                addSpacer(12)
            }
        }
        addSpacer(40)
    }

    private func createTitleLabel(_ text: String, fontSize: CGFloat) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.textColor = .white
            $0.font = .systemFont(ofSize: fontSize, weight: .semibold)
        }
    }

    private func createSubTitleLabel(title: String, count: Int, unit: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        let countText = "\(count)"
        let fullText = "\(title) \(countText)\(unit)"
        let attributedString = NSMutableAttributedString(string: fullText)
        let primaryColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: fullText.count))
        let countRange = (fullText as NSString).range(of: countText)
        attributedString.addAttribute(.foregroundColor, value: primaryColor, range: countRange)
        let unitRange = (fullText as NSString).range(of: unit)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1), range: unitRange)
        
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: fontSize, weight: .semibold)
        return label
    }

    private func createCard(type: CardType) -> UIView {
        let card = UIView().then {
            $0.backgroundColor = UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
            $0.layer.cornerRadius = 8
        }
        
        let actionButton = UIButton().then {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let primaryColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
            
            if type == .reviewed {
                $0.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
                $0.tintColor = .systemRed
            } else {
                $0.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
                $0.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .selected)
                $0.tintColor = (type == .recommended) ? primaryColor : .lightGray
                if type == .recommended { $0.isSelected = true }
                
                $0.addAction(UIAction { action in
                    guard let button = action.sender as? UIButton else { return }
                    button.isSelected.toggle()
                    button.tintColor = button.isSelected ? primaryColor : .lightGray
                }, for: .touchUpInside)
            }
        }
        
        card.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        
        return card
    }

    private func addSpacer(_ height: CGFloat) {
        let spacer = UIView()
        contentStackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { $0.height.equalTo(height) }
    }
}
