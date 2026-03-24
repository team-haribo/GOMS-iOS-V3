//
//  StudentCollectionViewCell.swift
//  Feature
//
//  Created by 김민선 on 3/23/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Kingfisher
import Service

public final class StudentCollectionViewCell: UICollectionViewCell {
    static let identifier = "StudentCell"
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 24
        $0.layer.borderWidth = 0
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .suit(size: 16, weight: .semibold)
        $0.textColor = .color.mainText.color
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 14, weight: .medium)
    }
    
    private lazy var editButton = UIButton().then {
        let image = UIImage(named: "Review", in: Bundle.module, compatibleWith: nil)
        $0.setImage(image, for: .normal)
        $0.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    private let dividerView = UIView().then {
        // 화이트/다크 모드 모두에서 잘 보이도록 sub1 색상 적용
        $0.backgroundColor = .color.sub1.color.withAlphaComponent(0.3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        [profileImageView, nameLabel, infoLabel, editButton, dividerView].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(14)
        }
        
        infoLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        editButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configureData(with userData: UserData) {
        let defaultImage = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        
        if let urlStr = userData.profileImageURL, let url = URL(string: urlStr) {
            profileImageView.kf.setImage(with: url, placeholder: defaultImage)
        } else {
            profileImageView.image = defaultImage
        }
        
        nameLabel.text = userData.name
        let displayMajor = userData.major == "SW" ? "SW개발" : userData.major
        infoLabel.text = "\(userData.grade)기 | \(displayMajor)"
        
        // 권한 및 상태에 따른 테두리 두께(4) 및 색상 처리
        if userData.authority == "ROLE_ADMIN" {
            profileImageView.layer.borderWidth = 4
            profileImageView.layer.borderColor = UIColor.color.admin.color.cgColor
            nameLabel.textColor = UIColor.color.admin.color
        } else if userData.isBlackList {
            profileImageView.layer.borderWidth = 4
            profileImageView.layer.borderColor = UIColor.systemRed.cgColor
            nameLabel.textColor = UIColor.systemRed
        } else {
            // 일반 학생은 테두리 없음
            profileImageView.layer.borderWidth = 0
            profileImageView.layer.borderColor = UIColor.clear.cgColor
            nameLabel.textColor = .color.mainText.color
        }
    }

    @objc private func editButtonTapped() {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? StudentManagementViewController {
                let bottomSheet = AuthorityBottomSheetVC(studentManagementVC: vc)
                vc.present(bottomSheet, animated: true)
                break
            }
            responder = responder?.next
        }
    }
}
