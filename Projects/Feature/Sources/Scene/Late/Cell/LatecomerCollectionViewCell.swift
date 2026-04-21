//
//  LatecomerCollectionViewCell.swift
//  Feature
//
//  Created by 김밈선 on 4/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Kingfisher
import Service

class LatecomerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "LatecomerCell"
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 24
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    private let studentInfoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .medium)
    }

    private let dividerView = UIView().then {
        $0.backgroundColor = .color.sub1.color.withAlphaComponent(0.3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addView() {
        [profileImageView, nameLabel, studentInfoLabel, dividerView].forEach { contentView.addSubview($0) }
    }
    
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.bottom.equalTo(contentView.snp.centerY).offset(-2)
        }
        
        studentInfoLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(contentView.snp.centerY).offset(2)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func configureData(lateData: LatecomerListData) {
        let defaultImage = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        
        if let imageURL = lateData.profileImageURL, let url = URL(string: imageURL) {
            profileImageView.kf.setImage(with: url, placeholder: defaultImage)
        } else {
            profileImageView.image = defaultImage
        }
        
        nameLabel.text = lateData.name
        
        let majorDisplayName: String
        switch lateData.department {
        case Major.sw.rawValue: majorDisplayName = "SW"
        case Major.iot.rawValue: majorDisplayName = "IoT"
        default: majorDisplayName = "AI"
        }
        
        studentInfoLabel.text = "\(lateData.grade)기 | \(majorDisplayName)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        studentInfoLabel.text = nil
    }
}
