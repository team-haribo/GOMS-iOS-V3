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
    
    private let dragHandle = UIView().then {
        $0.backgroundColor = .color.sub2.color
        $0.layer.cornerRadius = 2.5
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "짬뽕관 광주송정선운점"
        $0.textColor = .color.sub1.color
        $0.font = UIFont(name: "SUIT-SemiBold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "중식당"
        $0.textColor = .color.sub1.color
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    public let heartButton = UIButton().then {
        $0.setImage(UIImage(named: "Heart", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "GOMS_CloseButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    private let addressLabel = UILabel().then {
        $0.text = "광주 광산구 상무대로 277-11층"
        $0.textColor = .color.sub2.color
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "149m | 4분"
        $0.textColor = .color.sub2.color
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.text = "학생 후기 4 | 추천 17"
        $0.textColor = .color.sub2.color
        $0.font = UIFont(name: "SUIT-Medium", size: 14) ?? .systemFont(ofSize: 14)
    }
    
    public let arriveButton = UIButton().then {
        $0.setTitle("도착", for: .normal)
        $0.backgroundColor = .color.gomsPrimary.color
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: "SUIT-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 8 // 둥글기 줄임
    }
    
    public let startRouteButton = UIButton().then {
        $0.setTitle("출발", for: .normal)
        $0.backgroundColor = .color.button.color // button 색상 적용
        $0.setTitleColor(.color.sub1.color, for: .normal)
        $0.titleLabel?.font = UIFont(name: "SUIT-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 8 // 둥글기 줄임
    }
    
    private let reviewHeaderLabel = UILabel().then {
        let fullText = "학생 후기 4건"
        let attributedString = NSMutableAttributedString(string: fullText)
        let semiBoldFont = UIFont(name: "SUIT-SemiBold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        let mediumFont = UIFont(name: "SUIT-Medium", size: 22) ?? .systemFont(ofSize: 22)

        attributedString.addAttribute(.font, value: semiBoldFont, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.sub1.color, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.font, value: semiBoldFont, range: (fullText as NSString).range(of: "4"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.gomsPrimary.color, range: (fullText as NSString).range(of: "4"))
        attributedString.addAttribute(.font, value: mediumFont, range: (fullText as NSString).range(of: "건"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.sub2.color, range: (fullText as NSString).range(of: "건"))
        $0.attributedText = attributedString
    }

    public let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MapReviewCell.self, forCellReuseIdentifier: MapReviewCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        self.backgroundColor = .color.surface.color
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        [dragHandle, titleLabel, categoryLabel, heartButton, closeButton,
         addressLabel, infoLabel, reviewCountLabel, arriveButton, startRouteButton,
         reviewHeaderLabel, tableView].forEach { addSubview($0) }
    }
    
    private func setLayout() {
        dragHandle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36); $0.height.equalTo(5)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(dragHandle.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(24) // 24*24로 고정
        }
        heartButton.snp.makeConstraints {
            $0.centerY.equalTo(closeButton)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-8)
            $0.size.equalTo(24) // 24*24로 고정
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(closeButton)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.lessThanOrEqualTo(heartButton.snp.leading).offset(-10)
        }
        categoryLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(-2)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(24)
        }
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(24)
        }
        reviewCountLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(24)
        }
        arriveButton.snp.makeConstraints {
            $0.top.equalTo(reviewCountLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.width.equalTo(92); $0.height.equalTo(33)
        }
        startRouteButton.snp.makeConstraints {
            $0.centerY.equalTo(arriveButton)
            $0.leading.equalTo(arriveButton.snp.trailing).offset(8)
            $0.width.equalTo(92); $0.height.equalTo(33)
        }
        reviewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(arriveButton.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(reviewHeaderLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
