//  MapBottomSheetView.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

struct MapCardData {
    let id: UUID = UUID()
    var isFavorite: Bool
}

public final class MapBottomSheetView: UIView {
    public var onCardTapped: (() -> Void)?
    
    private var popularPlaces = [MapCardData(isFavorite: false), MapCardData(isFavorite: false), MapCardData(isFavorite: false)]
    private var recommendedPlaces = [MapCardData(isFavorite: true), MapCardData(isFavorite: true)]
    private var reviewPlaces = [MapCardData(isFavorite: false), MapCardData(isFavorite: false), MapCardData(isFavorite: false)]
    
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

    private func renderUI() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addSpacer(32)
        contentStackView.addArrangedSubview(createPopularTitleView())
        addSpacer(16)
        
        for (index, place) in popularPlaces.enumerated() {
            addCard(type: .popular, data: place, index: index)
            addSpacer(12)
        }
        
        addSpacer(28)
        contentStackView.addArrangedSubview(createTitleLabel("내 활동", fontSize: 22))
        addSpacer(16)
        
        if !recommendedPlaces.isEmpty {
            contentStackView.addArrangedSubview(createSubTitleLabel(title: "추천한 가게", count: recommendedPlaces.count, unit: "곳", fontSize: 18))
            addSpacer(16)
            for (index, place) in recommendedPlaces.enumerated() {
                addCard(type: .recommended, data: place, index: index)
                addSpacer(12)
            }
        }
        
        if !reviewPlaces.isEmpty {
            addSpacer(8)
            contentStackView.addArrangedSubview(createSubTitleLabel(title: "작성한 후기", count: reviewPlaces.count, unit: "건", fontSize: 18))
            addSpacer(16)
            for (index, _) in reviewPlaces.enumerated() {
                addCard(type: .reviewed, data: MapCardData(isFavorite: false), index: index)
                addSpacer(12)
            }
        }
        addSpacer(40)
    }

    private func addCard(type: MapCardType, data: MapCardData, index: Int) {
        let card = MapCardView(type: type)
        card.actionButton.isSelected = data.isFavorite
        card.actionButton.tintColor = data.isFavorite ? pointColor : UIColor.color.sub1.color

        if type == .reviewed {
            card.actionButton.tag = index
            card.actionButton.tintColor = UIColor.color.gomsNegative.color
            card.actionButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        } else {
            card.actionButton.tag = (type == .popular ? 100 : 200) + index
            card.actionButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
        }
        
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
        contentStackView.addArrangedSubview(card)
        card.snp.makeConstraints { $0.height.equalTo(105) }
    }

    @objc private func heartButtonTapped(_ sender: UIButton) {
        let isPopular = sender.tag < 200
        let index = isPopular ? sender.tag - 100 : sender.tag - 200
        
        if isPopular {
            popularPlaces[index].isFavorite.toggle()
            if popularPlaces[index].isFavorite {
                recommendedPlaces.insert(MapCardData(isFavorite: true), at: 0)
            } else {
                if !recommendedPlaces.isEmpty { recommendedPlaces.removeFirst() }
            }
        } else {
            if index < recommendedPlaces.count {
                recommendedPlaces.remove(at: index)
            }
        }
        renderUI()
    }

    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        if index < reviewPlaces.count {
            reviewPlaces.remove(at: index)
            renderUI()
        }
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

    private func createPopularTitleView() -> UIView {
        let titleLabel = createTitleLabel("최근 인기 장소", fontSize: 22)
        let fireImageView = UIImageView().then {
            $0.image = UIImage(named: "Fire", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.color.gomsNegative.color
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { $0.size.equalTo(24) }
        }
        let stack = UIStackView(arrangedSubviews: [titleLabel, fireImageView]).then {
            $0.axis = .horizontal; $0.alignment = .center; $0.spacing = 6.77
        }
        let container = UIView()
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.leading.top.bottom.equalToSuperview() }
        return container
    }

    private func addSpacer(_ height: CGFloat) {
        let spacer = UIView()
        contentStackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { $0.height.equalTo(height) }
    }
}
