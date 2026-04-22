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
import Kingfisher

public final class ReportDetailViewController: BaseViewController {
    
    public var reportData: ReportData?
    public var viewModel: ReportListViewModel?
    
    private lazy var customBackButton = UIButton().then {
        let backImage = UIImage(named: "Back", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        $0.setImage(backImage, for: .normal)
        $0.setTitle(" 돌아가기", for: .normal)
        $0.setTitleColor(UIColor.color.admin.color, for: .normal)
        $0.tintColor = UIColor.color.admin.color
        $0.titleLabel?.font = .suit(size: 18, weight: .medium)
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
        $0.textColor = UIColor.color.sub1.color
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
    }

    public override func shouldShowCustomNavigation() -> Bool {
        return false
    }
    
    private func updateUI() {
        guard let data = reportData else { return }
        
        switch data.reportStatus {
        case .pending:
            statusLabel.text = "처리전"
            statusLabel.textColor = UIColor.color.admin.color
            rejectButton.isHidden = false
            deleteButton.isHidden = false
        case .approved:
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

        
        targetNameLabel.text = data.reviewerName
        targetInfoLabel.text = "\(data.reviewerGrade)기 | \(data.reviewerDepartment)"

        if let urlString = data.profileImageUrl,
           let url = URL(string: urlString) {
            targetProfileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
            )
        } else {
            targetProfileImageView.image = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        }
        
        contentLabel.text = data.reportContent
        contentTimeLabel.text = formatDate(data.reportCreatedAt)
        reviewLabel.text = data.reviewContent
        reviewLocationAndTimeLabel.text = "\(data.location) | \(formatDate(data.reportCreatedAt))"
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func rejectButtonTapped() {
        guard let reportId = reportData?.reportId else { return }
        viewModel?.rejectReport(reportId: reportId) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.viewModel?.updateReportStatus(reportId: reportId, status: .rejected)
                self.viewModel?.filterType = .completed
                self.showAlert(title: "처리 완료", message: "신고가 기각되었습니다.", isSuccess: true)
            } else {
                self.showAlert(title: "오류", message: "처리에 실패했습니다.", isSuccess: false)
            }
        }
    }

    @objc private func deleteButtonTapped() {
        guard let reportId = reportData?.reportId else { return }

        viewModel?.resolveReport(reportId: reportId) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.viewModel?.updateReportStatus(reportId: reportId, status: .approved)
                self.viewModel?.filterType = .completed
                self.showAlert(title: "처리 완료", message: "리뷰가 삭제되었습니다.", isSuccess: true)
            } else {
                self.showAlert(title: "오류", message: "처리에 실패했습니다.", isSuccess: false)
            }
        }
    }

    private func showAlert(title: String, message: String, isSuccess: Bool) {
        GOMSAlert.show(
            in: self,
            title: title,
            message: message,
            actionTitle: "확인",
            cancelTitle: "",
            action: { [weak self] in
                if isSuccess {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        )
    }

    public override func addView() {
        [
            customBackButton, titleLabel, statusLabel,
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

        contentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
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
    private func formatDate(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        if let date = inputFormatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yy.MM.dd. HH:mm:ss"
            return outputFormatter.string(from: date)
        }
        
        // fallback (혹시 포맷 다를 때)
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = inputFormatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yy.MM.dd. HH:mm:ss"
            return outputFormatter.string(from: date)
        }
        
        return isoString
    }
}
