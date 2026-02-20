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
    
    // MARK: - UI Components
    private let dragHandle = UIView().then {
        $0.backgroundColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        $0.layer.cornerRadius = 2.5
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "짬뽕관 광주송정선운점"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "중식당"
        $0.textColor = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1)
        $0.font = .systemFont(ofSize: 14)
    }
    
    public let heartButton = UIButton().then {
        $0.setImage(UIImage(systemName: "heart"), for: .normal)
        $0.tintColor = .white
    }
    
    public let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
    }
    
    private let addressLabel = UILabel().then {
        $0.text = "광주 광산구 상무대로 277-11층"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "339m | 5분"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.text = "학생 후기 4 | 추천 17"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 12)
    }
    
    public let arriveButton = UIButton().then {
        $0.setTitle("도착", for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 180/255, blue: 50/255, alpha: 1)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        $0.layer.cornerRadius = 18
    }
    
    //  이름을 startRouteButton으로 변경하여 컨트롤러 에러 해결
    public let startRouteButton = UIButton().then {
        $0.setTitle("출발", for: .normal)
        $0.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        $0.layer.cornerRadius = 18
    }
    
    private let divider = UIView().then {
        $0.backgroundColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
    }
    
    private let reviewHeaderLabel = UILabel().then {
        $0.text = "학생 후기 4건"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }

    public let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MapReviewCell.self, forCellReuseIdentifier: MapReviewCell.identifier)
    }

    // MARK: - Init
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
         divider, reviewHeaderLabel, tableView].forEach { addSubview($0) }
    }
    
    private func setLayout() {
        dragHandle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36)
            $0.height.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dragHandle.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(-2)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(24)
        }
        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-12)
            $0.size.equalTo(24)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
        }
        
        reviewCountLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
        }
        
        arriveButton.snp.makeConstraints {
            $0.top.equalTo(reviewCountLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.width.equalTo(92)
            $0.height.equalTo(36)
        }
        
        startRouteButton.snp.makeConstraints {
            $0.centerY.equalTo(arriveButton)
            $0.leading.equalTo(arriveButton.snp.trailing).offset(8)
            $0.width.equalTo(92)
            $0.height.equalTo(36)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(arriveButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        reviewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(reviewHeaderLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
