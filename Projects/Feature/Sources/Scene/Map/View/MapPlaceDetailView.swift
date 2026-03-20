//
//  MapPlaceDetailView.swift
//  Feature
//
//  Created by 김민선 on 2/20/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class MapPlaceDetailView: UIView {
    
    private enum Metric {
        static let topMargin: CGFloat = 34
        static let sideMargin: CGFloat = 24
        static let iconSize: CGFloat = 30
        static let buttonHeight: CGFloat = 33
    }
    
    // MARK: - UI Components
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    private let contentView = UIView()
    
    private let dragHandle = UIView().then {
        $0.backgroundColor = .color.sub2.color
        $0.layer.cornerRadius = 2.5
    }

    public let titleLabel = UILabel().then {
        $0.text = "짬뽕관 광주송정선운점"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 22, weight: .bold)
    }
    
    public let categoryLabel = UILabel().then {
        $0.text = "중식당"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    // 🔥 하트 버튼 수정: normal과 selected에 다른 이미지를 할당
    public let heartButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        
        // 빈 하트 (테두리)
        let emptyHeart = UIImage(systemName: "heart")?.withConfiguration(config).withRenderingMode(.alwaysTemplate)
        // 채워진 하트 (속이 꽉 찬 것)
        let filledHeart = UIImage(systemName: "heart.fill")?.withConfiguration(config).withRenderingMode(.alwaysTemplate)
        
        $0.setImage(emptyHeart, for: .normal)
        $0.setImage(filledHeart, for: .selected)
        
        $0.tintColor = .color.sub2.color // 기본 회색
    }
    
    public let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "cancelButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let addressLabel = UILabel().then {
        $0.text = "광주 광산구 상무대로 277-11층"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "149m | 4분"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.text = "학생 후기 4 | 추천 17"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    public let arriveButton = UIButton().then {
        $0.setTitle("도착", for: .normal)
        $0.backgroundColor = .color.gomsPrimary.color
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .suit(size: 15, weight: .bold)
        $0.layer.cornerRadius = 8
    }
    
    public let startRouteButton = UIButton().then {
        $0.setTitle("출발", for: .normal)
        $0.backgroundColor = .color.button.color
        $0.setTitleColor(.color.sub1.color, for: .normal)
        $0.titleLabel?.font = .suit(size: 15, weight: .bold)
        $0.layer.cornerRadius = 8
    }
    
    private let reviewHeaderLabel = UILabel().then {
        let fullText = "학생 후기 4건"
        let attributedString = NSMutableAttributedString(string: fullText)
        let font = UIFont.suit(size: 22, weight: .bold)
        
        attributedString.addAttribute(.font, value: font, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.mainText.color, range: (fullText as NSString).range(of: "학생 후기"))
        
        attributedString.addAttribute(.font, value: font, range: (fullText as NSString).range(of: "4"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.gomsPrimary.color, range: (fullText as NSString).range(of: "4"))
        
        attributedString.addAttribute(.font, value: font, range: (fullText as NSString).range(of: "건"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.sub2.color, range: (fullText as NSString).range(of: "건"))
        $0.attributedText = attributedString
    }

    public let reviewWriteButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.title = "후기 남기기"
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        config.image = UIImage(named: "Review", in: Bundle.module, compatibleWith: nil)?.withConfiguration(imageConfig).withRenderingMode(.alwaysTemplate)
        config.imagePadding = 6
        config.baseForegroundColor = .color.sub2.color
        $0.configuration = config
    }

    public let tableView = IntrinsicTableView().then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.separatorStyle = .singleLine
        $0.separatorColor = .color.sub2.color.withAlphaComponent(0.2)
        $0.register(MapReviewCell.self, forCellReuseIdentifier: MapReviewCell.identifier)
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setLayout()
        bindActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = .color.surface.color
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(dragHandle)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, categoryLabel, heartButton, closeButton,
         addressLabel, infoLabel, reviewCountLabel, arriveButton, startRouteButton,
         reviewHeaderLabel, reviewWriteButton, tableView].forEach { contentView.addSubview($0) }
    }
    
    private func setLayout() {
        dragHandle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36); $0.height.equalTo(5)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(dragHandle.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Metric.topMargin)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(-2)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(Metric.sideMargin)
            $0.size.equalTo(Metric.iconSize)
        }
        
        heartButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-4)
            $0.size.equalTo(Metric.iconSize)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        reviewCountLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        arriveButton.snp.makeConstraints {
            $0.top.equalTo(reviewCountLabel.snp.bottom).offset(14)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
            $0.width.equalTo(92); $0.height.equalTo(Metric.buttonHeight)
        }
        
        startRouteButton.snp.makeConstraints {
            $0.centerY.equalTo(arriveButton)
            $0.leading.equalTo(arriveButton.snp.trailing).offset(8)
            $0.width.equalTo(92); $0.height.equalTo(Metric.buttonHeight)
        }
        
        reviewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(arriveButton.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        reviewWriteButton.snp.makeConstraints {
            $0.centerY.equalTo(reviewHeaderLabel)
            $0.trailing.equalToSuperview().inset(Metric.sideMargin)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(reviewHeaderLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func bindActions() {
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
    }

    // 🔥 색상과 상태를 동시에 변경
    @objc private func heartButtonTapped() {
        heartButton.isSelected.toggle()
        heartButton.tintColor = heartButton.isSelected ? .color.gomsPrimary.color : .color.sub2.color
    }
}

public final class IntrinsicTableView: UITableView {
    override public var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
