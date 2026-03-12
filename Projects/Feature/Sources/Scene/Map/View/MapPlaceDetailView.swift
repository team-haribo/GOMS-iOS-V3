//
//  MapPlaceDetailView.swift
//  Feature
//
//  Created by 김민선 on 2/20/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//
// 하트 눌렀을때 GOMS_Primary색 다시 누르면 원래대로
// 학생후기 4건 글씨에서 학생후기는 크기 22 SUIT-SemiBold 4랑 건은 크기 19 SUIT-Medium 4는 GOMS_Primary색
// 후기남기기는 SUIT-Medium 크기 20
// 리뷰 구분하는 얇은 회색선 끝까지 안가게 그리고 더 앏게
// 그리고 후기 남기기 위치 왼쪽 벽 끝에서 가로 간격 24 학생후기4건 글씨와 같은줄
// 그리고 지금은 다 임시로 글자 넣은거니까 나중에 서버통신할때 한 파일만 지우면 되게 따로 파일 만들어서 데이터 넣고 싶어서 내용 비워주고
// 데이터 넣고 싶어서 내용 비워주고 따로 파일 만들어서 확인할 수 있게 해줘
// 다른 구조는건들이지 말고 쓸데없는 주석 다 빼고 하드코딩 절대 하지 않게
// 그리고 후기 없을때 Cup 아이콘 색 sub2 넣고 글 SUIT-Medium 글자 크기 34 색 sub2


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
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0) // [수정] 탭바 높이만큼 여백 추가
    }
    
    private let contentView = UIView()
    
    private let dragHandle = UIView().then {
        $0.backgroundColor = .color.sub2.color
        $0.layer.cornerRadius = 2.5
    }

    public let titleLabel = UILabel().then {
        $0.text = "짬뽕관 광주송정선운점"
        $0.textColor = .color.sub1.color
        $0.font = UIFont(name: "SUIT-SemiBold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
    }
    
    public let categoryLabel = UILabel().then {
        $0.text = "중식당"
        $0.textColor = .color.sub2.color
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    public let heartButton = UIButton().then {
        $0.setImage(UIImage(named: "Hart", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "cancelButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let addressLabel = UILabel().then {
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
        $0.font = UIFont(name: "SUIT-Medium", size: 16) ?? .systemFont(ofSize: 16)
    }
    
    public let arriveButton = UIButton().then {
        $0.setTitle("도착", for: .normal)
        $0.backgroundColor = .color.gomsPrimary.color
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: "SUIT-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)
        $0.layer.cornerRadius = 8
    }
    
    public let startRouteButton = UIButton().then {
        $0.setTitle("출발", for: .normal)
        $0.backgroundColor = .color.button.color
        $0.setTitleColor(.color.sub1.color, for: .normal)
        $0.titleLabel?.font = UIFont(name: "SUIT-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)
        $0.layer.cornerRadius = 8
    }
    
    private let reviewHeaderLabel = UILabel().then {
        let fullText = "학생 후기 4건"
        let attributedString = NSMutableAttributedString(string: fullText)
        let font = UIFont(name: "SUIT-SemiBold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        attributedString.addAttribute(.font, value: font, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.sub1.color, range: (fullText as NSString).range(of: "학생 후기"))
        attributedString.addAttribute(.font, value: font, range: (fullText as NSString).range(of: "4"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.gomsPrimary.color, range: (fullText as NSString).range(of: "4"))
        attributedString.addAttribute(.font, value: font, range: (fullText as NSString).range(of: "건"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color.sub2.color, range: (fullText as NSString).range(of: "건"))
        $0.attributedText = attributedString
    }

    public let writeReviewButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.title = "후기 남기기"
        config.image = UIImage(named: "Review", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        config.imagePadding = 4
        config.baseForegroundColor = .color.sub2.color
        $0.configuration = config
    }

    public let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.separatorStyle = .singleLine
        $0.separatorColor = .color.sub2.color
        $0.register(MapReviewCell.self, forCellReuseIdentifier: MapReviewCell.identifier)
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
        
        addSubview(dragHandle)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, categoryLabel, heartButton, closeButton,
         addressLabel, infoLabel, reviewCountLabel, arriveButton, startRouteButton,
         reviewHeaderLabel, writeReviewButton, tableView].forEach { contentView.addSubview($0) }
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
        
        writeReviewButton.snp.makeConstraints {
        $0.centerY.equalTo(reviewHeaderLabel)
            $0.trailing.equalToSuperview().inset(Metric.sideMargin)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(reviewHeaderLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}
