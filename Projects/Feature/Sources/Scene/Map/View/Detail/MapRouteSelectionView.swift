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

public enum RouteStartLocationType {
    case currentLocation
    case school
}

extension RouteStartLocationType {
    init(from type: MapViewController.StartLocationType) {
        switch type {
        case .currentLocation: self = .currentLocation
        case .school: self = .school
        }
    }
}


public struct RouteCardData {
    public let title: String
    public let time: String
    public let info: String

    public init(title: String, time: String, info: String) {
        self.title = title
        self.time = time
        self.info = info
    }
}

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
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    private let infoLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 14, weight: .regular)
    }
    
    public var title: String { titleLabel.text ?? "" }
    
    public init(title: String, time: String, info: String) {
        super.init(frame: .zero)
        self.backgroundColor = .color.surface.color
        self.layer.cornerRadius = 12
        titleLabel.text = title
        timeLabel.text = time
        infoLabel.text = info
        [titleLabel, arrowIcon, timeLabel, infoLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        arrowIcon.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(2)
            $0.size.equalTo(12)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeLabel)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

public final class MapRouteSelectionView: UIView {
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let converted = containerView.convert(point, from: self)
        if containerView.bounds.contains(converted) {
            return true
        }

        let convertedCard = recommendationStackView.convert(point, from: self)
        if recommendationStackView.bounds.contains(convertedCard) {
            return true
        }

        return false
    }
    
    private let locations = ["내 위치", "학교"]
    private var destinationName: String = "짬뽕관 광주송정선운점"
    
    private var isSelectingStart = true
    
    public var onCardTapped: ((String) -> Void)?
    public var onStartLocationChanged: ((RouteStartLocationType) -> Void)?
    public var onEndLocationChanged: ((RouteStartLocationType) -> Void)?
    public var onReverseTapped: (() -> Void)?
    
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
        $0.backgroundColor = .color.sub3.color
        $0.layer.cornerRadius = 8
        $0.contentHorizontalAlignment = .leading
    }
    private let startLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 17, weight: .medium)
    }
    private let startArrow = UIImageView().then {
        $0.image = UIImage(named: "Down directional", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
    
    public let endDropdownButton = UIButton().then {
        $0.backgroundColor = .color.sub3.color
        $0.layer.cornerRadius = 8
        $0.contentHorizontalAlignment = .leading
    }
    private let endLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 17, weight: .medium)
    }
    private let endArrow = UIImageView().then {
        $0.image = UIImage(named: "Down directional", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    private let selectionBox = UIView().then {
        $0.backgroundColor = .color.sub3.color
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
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

    private let line = UIView().then { $0.backgroundColor = .color.sub2.color.withAlphaComponent(0.25) }
    private let endTitleLabel = UILabel().then {
        $0.text = "도착"
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .medium)
    }

    public lazy var endLocationLabel = UILabel().then {
        $0.text = "    \(destinationName)"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 17, weight: .medium)
        $0.backgroundColor = .color.sub3.color
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    public let reverseButton = UIButton().then {
        $0.setImage(UIImage(named: "Shift", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.gomsPrimary.color
    }

    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }

    public let recommendationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fill
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    public func setStartLocation(_ type: RouteStartLocationType) {
        let title: String
        switch type {
        case .currentLocation:
            title = locations[0]
        case .school:
            title = locations[1]
        }
        startLabel.text = title
    }

    public func setStartPlaceName(_ name: String) {
        startLabel.text = name
    }

    public func setEndPlaceName(_ name: String) {
        endLabel.text = name
    }

    public func setEndLocation(_ type: RouteStartLocationType) {
        let title: String
        switch type {
        case .currentLocation:
            title = locations[0]
        case .school:
            title = locations[1]
        }
        endLabel.text = title
    }

    private func setupLayout() {
        addSubview(containerView)
        [startTitleLabel, backButton, startDropdownButton, endTitleLabel, endDropdownButton, reverseButton, selectionBox].forEach {
            containerView.addSubview($0)
        }
        [myLocationBtn, schoolLocationBtn, line].forEach { selectionBox.addSubview($0) }
        addSubview(scrollView)
        scrollView.addSubview(recommendationStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(endDropdownButton.snp.bottom).offset(24)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(24)
        }

        startTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.leading.equalTo(backButton.snp.trailing).offset(4)
        }

        startDropdownButton.snp.makeConstraints {
            $0.top.equalTo(startTitleLabel.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(52)
        }

       
        startDropdownButton.addSubview(startLabel)
        startDropdownButton.addSubview(startArrow)
        startLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(startArrow.snp.leading).offset(-8)
        }
        startArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
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
            $0.centerY.equalTo(startDropdownButton.snp.bottom).offset(8)
            $0.size.equalTo(24)
        }

        endTitleLabel.snp.makeConstraints {
            $0.top.equalTo(startDropdownButton.snp.bottom).offset(16)
            $0.leading.equalTo(startTitleLabel)
        }
        
        endDropdownButton.snp.makeConstraints {
            $0.top.equalTo(endTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(52)
        }
       
        endDropdownButton.addSubview(endLabel)
        endDropdownButton.addSubview(endArrow)
        endLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(endArrow.snp.leading).offset(-8)
        }
        endArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }

        scrollView.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(106)
        }

        recommendationStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equalToSuperview()
        }
    }

    private func setupActions() {
        startDropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)
        endDropdownButton.addTarget(self, action: #selector(didTapEndDropdown), for: .touchUpInside)
        myLocationBtn.addTarget(self, action: #selector(didSelectOption), for: .touchUpInside)
        schoolLocationBtn.addTarget(self, action: #selector(didSelectOption), for: .touchUpInside)
        reverseButton.addTarget(self, action: #selector(didTapReverse), for: .touchUpInside)
    }

    @objc private func didTapDropdown() {
        isSelectingStart = true
        selectionBox.isHidden.toggle()
        containerView.bringSubviewToFront(selectionBox)


        endDropdownButton.isUserInteractionEnabled = false

     
        startDropdownButton.isUserInteractionEnabled = true
    }

    @objc private func didTapEndDropdown() {
        isSelectingStart = false
        selectionBox.isHidden.toggle()
        containerView.bringSubviewToFront(selectionBox)

        
        startDropdownButton.isUserInteractionEnabled = false

        endDropdownButton.isUserInteractionEnabled = true
    }

    @objc private func didSelectOption(_ sender: UIButton) {
        guard let title = sender.configuration?.attributedTitle else { return }
        let plainTitle = String(title.characters)
        let selectedType: RouteStartLocationType = (plainTitle == locations[0]) ? .currentLocation : .school

        if isSelectingStart {
            startLabel.text = plainTitle
            onStartLocationChanged?(selectedType)
        } else {
            endLabel.text = plainTitle
            onEndLocationChanged?(selectedType)
        }

        startDropdownButton.isUserInteractionEnabled = true
        endDropdownButton.isUserInteractionEnabled = true

        selectionBox.isHidden = true
    }

    @objc private func didTapReverse() {
        
        isSelectingStart.toggle()

        
        selectionBox.isHidden = true

      
        onReverseTapped?()
    }

    public func configure(routes: [RouteCardData]) {
        recommendationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        routes.forEach { route in
            let card = PathRecommendationCard(
                title: route.title,
                time: route.time,
                info: route.info
            )

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard(_:)))
            card.addGestureRecognizer(tapGesture)

            recommendationStackView.addArrangedSubview(card)

            card.snp.makeConstraints {
                $0.width.equalTo(192)
            }
        }
    }

    
    @objc private func didTapCard(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view as? PathRecommendationCard else { return }
        onCardTapped?(card.title)
    }
    public func setEndFixed(_ isFixed: Bool) {
        endArrow.isHidden = isFixed
        endDropdownButton.isUserInteractionEnabled = !isFixed
        endDropdownButton.contentHorizontalAlignment = .leading
    }

    public func setStartFixed(_ isFixed: Bool) {
        startArrow.isHidden = isFixed
        startDropdownButton.isUserInteractionEnabled = !isFixed
        startDropdownButton.contentHorizontalAlignment = .leading
    }
    public func swapLocations() {
        let temp = startLabel.text
        startLabel.text = endLabel.text
        endLabel.text = temp
        // Swap arrow visibility if needed (if fixed state swapping is required elsewhere)
    }
}
