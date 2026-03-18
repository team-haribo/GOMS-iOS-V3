//
//  OutingStatusCollectionViewCell.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

import SnapKit
import Then
import Kingfisher

final class OutingStatusCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    static let identifier = "OutingStatusCell"

    let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))

    let nameLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = UIFont.suit(size: 16, weight: .semibold)
    }

    let studentInfoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 13, weight: .medium)
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addView()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with data: OutingListData) {
        setupData(with: data)
    }

    // MARK: - Dummy UI
    func configureDummy() {
        profileImageView.image = .image.profile.image
        nameLabel.text = "김민솔"
        studentInfoLabel.text = "8기 | AI"
    }

    public func setupData(with outingData: OutingListData) {
        if let imageURL = outingData.profileImageURL, let url = URL(string: imageURL) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
        } else {
            profileImageView.image = .image.profile.image
        }
        nameLabel.text = outingData.name
        if outingData.major == Major.sw.rawValue {
            studentInfoLabel.text = "\(outingData.grade)기 | SW개발"
        } else if outingData.major == Major.iot.rawValue {
            studentInfoLabel.text = "\(outingData.grade)기 | IoT"
        } else {
            studentInfoLabel.text = "\(outingData.grade)기 | AI"
        }
    }

    // MARK: - Configure UI
    private func configureUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    // MARK: - Add View
    private func addView() {
        [profileImageView, nameLabel, studentInfoLabel].forEach { contentView.addSubview($0) }
    }

    // MARK: - Layout
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(28)
            $0.leading.equalToSuperview().inset(2)
            $0.centerY.equalToSuperview()
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        studentInfoLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(2)
        }
    }
}
