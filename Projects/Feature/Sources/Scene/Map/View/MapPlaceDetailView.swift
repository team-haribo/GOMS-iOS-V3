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
        $0.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        $0.layer.cornerRadius = 2.5
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "짬뽕관 광주송정선운점"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 22, weight: .bold)
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "중식당"
        $0.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        $0.font = .systemFont(ofSize: 16)
    }
    
    public let heartButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    public let closeButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        $0.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    }
    
    private let addressLabel = UILabel().then {
        $0.text = "광주 광산구 상무대로 277-11층"
        $0.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.font = .systemFont(ofSize: 16)
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "149m | 4분"
        $0.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.font = .systemFont(ofSize: 16)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.text = "학생 후기 4 | 추천 17"
        $0.textColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
        $0.font = .systemFont(ofSize: 14)
    }
    
    public let arriveButton = UIButton().then {
        $0.setTitle("도착", for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 16.5
    }
    
    public let startRouteButton = UIButton().then {
        $0.setTitle("출발", for: .normal)
        $0.backgroundColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
        $0.setTitleColor(UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 16.5
    }
    
    private let reviewHeaderLabel = UILabel().then {
        let fullText = "학생 후기 4건"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1), range: (fullText as NSString).range(of: "4"))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1), range: (fullText as NSString).range(of: "건"))
        $0.attributedText = attributedString
        $0.font = .systemFont(ofSize: 22, weight: .bold)
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
        self.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
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
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dragHandle.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.lessThanOrEqualTo(heartButton.snp.leading).offset(-10)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(-4)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(28)
        }
        
        heartButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-4)
            $0.size.equalTo(28)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
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
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview() // 시트 끝까지 채우기
        }
    }
}
