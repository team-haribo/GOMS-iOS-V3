//
//  LateCell.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class LateCell: UICollectionViewCell {

    // MARK: - Properties
    static let identifier = "LateCell"

    let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))

    let nameLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .color.sub1.color
    }

    let studentInfoLabel = UILabel().then {
        $0.font = .suit(size: 14, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .color.sub2.color
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .color.surface.color

        addView()
        configureUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with data: LatecomerData) {
        setupData(with: data)
    }

    func configureDummy() {
        profileImageView.image = .image.profile.image
        nameLabel.text = "김민솔"
        studentInfoLabel.text = "8기 | AI"
    }

    public func setupData(with lateData: LatecomerData) {
        if let imageURL = lateData.profileImageURL, let url = URL(string: imageURL) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.crop.circle.fill"))
        } else {
            profileImageView.image = .image.profile.image
        }
        nameLabel.text = lateData.name
        if lateData.major == Major.sw.rawValue {
            studentInfoLabel.text = "\(lateData.grade)기 | SW개발"
        } else if lateData.major == Major.iot.rawValue {
            studentInfoLabel.text = "\(lateData.grade)기 | IoT"
        } else {
            studentInfoLabel.text = "\(lateData.grade)기 | AI"
        }
    }

    private func configureUI() {
        self.backgroundColor = .color.gomsCardBackgroundColor.color
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    // MARK: - Add View
    private func addView() {
        [profileImageView, nameLabel, studentInfoLabel].forEach { self.addSubview($0) }
    }

    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(56)
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
        }

        nameLabel.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.top.equalTo(profileImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        studentInfoLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
}
