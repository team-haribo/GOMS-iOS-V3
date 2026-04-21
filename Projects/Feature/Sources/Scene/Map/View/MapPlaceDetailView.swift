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
    
    // MARK: - Metric
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
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 22, weight: .bold)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byWordWrapping
    }
    
    public let categoryLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
        // MARK: - FIX (Compression Resistance)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    public let heartButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let emptyHeart = UIImage(named: "Hart", in: Bundle.module, compatibleWith: nil)?
            .withConfiguration(config)
            .withRenderingMode(.alwaysTemplate)
        let filledHeart = UIImage(systemName: "heart.fill")?
            .withConfiguration(config)
            .withRenderingMode(.alwaysTemplate)
        
        $0.setImage(emptyHeart, for: .normal)
        $0.setImage(filledHeart, for: .selected)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.tintColor = .color.sub2.color
    }
    
    public let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "cancelButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let addressLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    public let infoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    private let reviewCountLabel = UILabel().then {
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
    
    private let reviewHeaderLabel = UILabel()

    public let reviewWriteButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.title = "후기 남기기"
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)
        config.image = UIImage(named: "Review", in: Bundle.module, compatibleWith: nil)?
            .withConfiguration(imageConfig)
            .withRenderingMode(.alwaysTemplate)
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
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 100
    }

    private let emptyReviewStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
        $0.isHidden = true
    }

    private let emptyIconView = UIImageView().then {
        $0.image = UIImage(named: "Coffee", in: Bundle.module, compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate)
        $0.tintColor = .color.sub2.color
        $0.contentMode = .scaleAspectFit
    }

    private let emptyLabel = UILabel().then {
        $0.text = "아직 후기가 없어요!\n첫 후기를 작성해봐요!"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = .suit(size: 18, weight: .medium)
        $0.textColor = .color.sub2.color
    }

    // MARK: - Properties
    private var reviews: [MapReview] = []
    public var onHeartToggled: ((Bool) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setLayout()
        bindActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configure
    public func configure(with data: MapPlaceDetailModel, distanceText: String, timeText: String, reviews: [MapReview]) {
        titleLabel.text = data.placeName
        let categories = data.categoryName.split(separator: ">").map { $0.trimmingCharacters(in: .whitespaces) }
        categoryLabel.text = categories.last
        addressLabel.text = data.roadAddress
        infoLabel.isHidden = false
        infoLabel.text = "\(distanceText) | \(timeText)"
        heartButton.isSelected = data.recommended
        heartButton.tintColor = data.recommended ? .color.gomsPrimary.color : .color.sub2.color
        
        updateReviewCount(data.reviewCount, recommendCount: data.recommendCount)
        
        self.reviews = reviews
        // MARK: - FIXED (Data Sync)
        tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }

    public func updateReviewCount(_ count: Int, recommendCount: Int) {
        reviewCountLabel.text = "학생 후기 \(count) | 추천 \(recommendCount)"
        
        let fullText = "학생 후기 \(count)건"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.mainText.color, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.gomsPrimary.color, range: (fullText as NSString).range(of: "\(count)"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.sub2.color, range: (fullText as NSString).range(of: "건"))
        
        let titleFont = UIFont.suit(size: 18, weight: .semibold)
        let countFont = UIFont.suit(size: 15, weight: .medium)
        let unitFont = UIFont.suit(size: 15, weight: .medium)

        let nsString = fullText as NSString

        attributedString.addAttribute(.font, value: titleFont, range: nsString.range(of: "학생 후기"))
        attributedString.addAttribute(.font, value: countFont, range: nsString.range(of: "\(count)"))
        attributedString.addAttribute(.font, value: unitFont, range: nsString.range(of: "건"))

        
        let baselineOffset: CGFloat = (titleFont.lineHeight - countFont.lineHeight) / 2

        attributedString.addAttribute(.baselineOffset, value: baselineOffset, range: nsString.range(of: "\(count)"))
        attributedString.addAttribute(.baselineOffset, value: baselineOffset, range: nsString.range(of: "건"))
        
        reviewHeaderLabel.attributedText = attributedString
        
        let hasReviews = count > 0
        tableView.isHidden = !hasReviews
        emptyReviewStackView.isHidden = hasReviews
    }

    // MARK: - Setup
    private func setupView() {
        self.backgroundColor = .color.surface.color
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(dragHandle)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [emptyIconView, emptyLabel].forEach { emptyReviewStackView.addArrangedSubview($0) }
        
        [titleLabel, categoryLabel, heartButton, closeButton,
         addressLabel, infoLabel, reviewCountLabel, arriveButton, startRouteButton,
         reviewHeaderLabel, reviewWriteButton, tableView, emptyReviewStackView].forEach { contentView.addSubview($0) }
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
            $0.trailing.lessThanOrEqualTo(heartButton.snp.leading).offset(-8)
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
            $0.trailing.equalToSuperview().inset(Metric.sideMargin)
        }

        infoLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
            $0.trailing.equalToSuperview().inset(Metric.sideMargin)
        }

        reviewCountLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        arriveButton.snp.makeConstraints {
            $0.top.equalTo(reviewCountLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
            $0.width.equalTo(92); $0.height.equalTo(Metric.buttonHeight)
        }
        
        startRouteButton.snp.makeConstraints {
            $0.centerY.equalTo(arriveButton)
            $0.leading.equalTo(arriveButton.snp.trailing).offset(8)
            $0.width.equalTo(92); $0.height.equalTo(Metric.buttonHeight)
        }
        
        reviewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(arriveButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(Metric.sideMargin)
        }
        
        reviewWriteButton.snp.makeConstraints {
            $0.centerY.equalTo(reviewHeaderLabel)
            $0.trailing.equalToSuperview().inset(Metric.sideMargin)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(reviewHeaderLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.bottom.equalTo(tableView.snp.bottom).offset(20)
        }

        emptyReviewStackView.snp.makeConstraints {
            $0.top.equalTo(reviewHeaderLabel.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-60)
        }
        emptyIconView.snp.makeConstraints {
            $0.width.height.equalTo(110)
        }
    }

    // MARK: - Actions
    private func bindActions() {
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
    }

    @objc private func heartButtonTapped() {
        heartButton.isSelected.toggle()
        heartButton.tintColor = heartButton.isSelected ? .color.gomsPrimary.color : .color.sub2.color
        onHeartToggled?(heartButton.isSelected)
    }
}

