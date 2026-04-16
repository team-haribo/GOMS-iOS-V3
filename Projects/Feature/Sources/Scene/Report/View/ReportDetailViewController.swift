//
//  ReportDetailViewController.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class ReportDetailViewController: BaseViewController {
    
    public var reportData: ReportData?
    public var viewModel: ReportListViewModel?
    
    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.titleLabel?.font = .suit(size: 16, weight: .medium)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    private let titleLabel = UILabel().then {
        $0.text = "신고 조회"
        $0.font = .suit(size: 26, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let statusLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .medium)
    }

    private let reporterTitleLabel = UILabel().then {
        $0.text = "신고자"
        $0.font = .suit(size: 20, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let reporterProfileImageView = UIImageView().then {
        $0.image = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
    }

    private let reporterNameLabel = UILabel().then {
        $0.font = .suit(size: 20, weight: .semibold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let reporterInfoLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
    }

    private let contentTitleLabel = UILabel().then {
        $0.text = "신고 내용"
        $0.font = .suit(size: 18, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let contentContainerView = UIView().then {
        $0.backgroundColor = UIColor.color.surface.color
        $0.layer.cornerRadius = 12
    }

    private let contentLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = UIColor.color.sub1.color
        $0.numberOfLines = 0
    }

    private let contentTimeLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
    }

    private let targetTitleLabel = UILabel().then {
        $0.text = "신고 대상자"
        $0.font = .suit(size: 20, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let targetProfileImageView = UIImageView().then {
        $0.image = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
    }

    private let targetNameLabel = UILabel().then {
        $0.font = .suit(size: 20, weight: .semibold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let targetInfoLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
    }

    private let reviewTitleLabel = UILabel().then {
        $0.text = "후기 내용"
        $0.font = .suit(size: 18, weight: .bold)
        $0.textColor = UIColor.color.mainText.color
    }

    private let reviewContainerView = UIView().then {
        $0.backgroundColor = UIColor.color.surface.color
        $0.layer.cornerRadius = 12
    }

    private let reviewLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .medium)
        $0.textColor = UIColor.color.sub1.color
        $0.numberOfLines = 0
    }

    private let reviewLocationAndTimeLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textColor = UIColor.color.sub2.color
        $0.textAlignment = .right
    }

    private lazy var rejectButton = UIButton().then {
        $0.setTitle("기각", for: .normal)
        $0.setTitleColor(UIColor.color.sub2.color, for: .normal)
        $0.backgroundColor = UIColor.color.surface.color
        $0.titleLabel?.font = .suit(size: 16, weight: .semibold)
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
    }

    private lazy var deleteButton = UIButton().then {
        $0.setTitle("리뷰 삭제", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.color.gomsNegative.color
        $0.titleLabel?.font = .suit(size: 16, weight: .semibold)
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.subviews.forEach {
            if $0 != customBackButton && $0 != titleLabel && $0.frame.height == 100 {
                $0.isHidden = true
                $0.removeFromSuperview()
            }
        }
    }
    
    private func updateUI() {
        guard let data = reportData else { return }
        
        switch data.reportStatus {
        case .pending:
            statusLabel.text = "처리전"
            statusLabel.textColor = UIColor.color.admin.color
            rejectButton.isHidden = false
            deleteButton.isHidden = false
        case .resolved:
            statusLabel.text = "처리 완료"
            statusLabel.textColor = UIColor.color.sub2.color
            rejectButton.isHidden = true
            deleteButton.isHidden = true
        case .rejected:
            statusLabel.text = "기각"
            statusLabel.textColor = UIColor.color.sub2.color
            rejectButton.isHidden = true
            deleteButton.isHidden = true
        }

        reporterNameLabel.text = "신고자"
        reporterInfoLabel.text = "정보 없음"
        
        targetNameLabel.text = data.reviewerName
        targetInfoLabel.text = "\(data.reviewerGrade)기 | \(data.reviewerDepartment)"
        
        contentLabel.text = data.reportContent
        contentTimeLabel.text = data.reportCreatedAt
        reviewLabel.text = data.reviewContent
        reviewLocationAndTimeLabel.text = "\(data.location) | \(data.reportCreatedAt)"
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func rejectButtonTapped() {
        guard let reportId = reportData?.reportId else { return }
        viewModel?.rejectReport(reportId: reportId) { [weak self] success in
            if success {
                self?.showAlert(title: "처리 완료", message: "신고가 기각되었습니다.", isSuccess: true)
            } else {
                self?.showAlert(title: "오류", message: "처리에 실패했습니다.", isSuccess: false)
            }
        }
    }

    @objc private func deleteButtonTapped() {
        guard let reviewId = reportData?.reviewId else { return }
        viewModel?.deleteReview(reviewId: reviewId) { [weak self] success in
            if success {
                self?.showAlert(title: "처리 완료", message: "리뷰가 삭제되었습니다.", isSuccess: true)
            } else {
                self?.showAlert(title: "오류", message: "처리에 실패했습니다.", isSuccess: false)
            }
        }
    }

    private func showAlert(title: String, message: String, isSuccess: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            if isSuccess {
                self.navigationController?.popViewController(animated: true)
            }
        })
        self.present(alert, animated: true)
    }

    public override func addView() {
        [
            customBackButton, titleLabel, statusLabel,
            reporterTitleLabel, reporterProfileImageView, reporterNameLabel, reporterInfoLabel,
            contentTitleLabel, contentContainerView, contentTimeLabel,
            targetTitleLabel, targetProfileImageView, targetNameLabel, targetInfoLabel,
            reviewTitleLabel, reviewContainerView, reviewLocationAndTimeLabel,
            rejectButton, deleteButton
        ].forEach { view.addSubview($0) }
        
        contentContainerView.addSubview(contentLabel)
        reviewContainerView.addSubview(reviewLabel)
        
        view.bringSubviewToFront(customBackButton)
    }

    public override func setLayout() {
        customBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(customBackButton.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }

        statusLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(24)
        }

        reporterTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }

        reporterProfileImageView.snp.makeConstraints {
            $0.top.equalTo(reporterTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(24)
            $0.size.equalTo(48)
        }

        reporterNameLabel.snp.makeConstraints {
            $0.top.equalTo(reporterProfileImageView).offset(2)
            $0.leading.equalTo(reporterProfileImageView.snp.trailing).offset(12)
        }

        reporterInfoLabel.snp.makeConstraints {
            $0.top.equalTo(reporterNameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(reporterNameLabel)
        }

        contentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(reporterProfileImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }

        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(contentTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.greaterThanOrEqualTo(54)
        }

        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        contentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(contentContainerView.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(24)
        }

        targetTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentTimeLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }

        targetProfileImageView.snp.makeConstraints {
            $0.top.equalTo(targetTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(24)
            $0.size.equalTo(48)
        }

        targetNameLabel.snp.makeConstraints {
            $0.top.equalTo(targetProfileImageView).offset(2)
            $0.leading.equalTo(targetProfileImageView.snp.trailing).offset(12)
        }

        targetInfoLabel.snp.makeConstraints {
            $0.top.equalTo(targetNameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(targetNameLabel)
        }

        reviewTitleLabel.snp.makeConstraints {
            $0.top.equalTo(targetProfileImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(24)
        }

        reviewContainerView.snp.makeConstraints {
            $0.top.equalTo(reviewTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.greaterThanOrEqualTo(54)
        }

        reviewLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        reviewLocationAndTimeLabel.snp.makeConstraints {
            $0.top.equalTo(reviewContainerView.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(24)
        }

        rejectButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(52)
            $0.trailing.equalTo(view.snp.centerX).offset(-2)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(52)
            $0.leading.equalTo(view.snp.centerX).offset(2)
        }
    }
}
