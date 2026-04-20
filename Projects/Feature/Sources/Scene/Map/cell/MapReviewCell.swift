//
//  MapReviewCell.swift
//  Feature
//
//  Created by 김민선 on 2/20/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Kingfisher

public final class MapReviewCell: UITableViewCell {
    public static let identifier = "MapReviewCell"
    
    public var onDeleteTap: (() -> Void)?
    public var onReportTap: (() -> Void)?
    
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .systemGray6
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .bold)
    }
    
    private let infoLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .medium)
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 15, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 13, weight: .medium)
    }
    
    public let actionButton = UIButton().then {
        $0.tintColor = .color.sub2.color
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        onDeleteTap = nil
        onReportTap = nil
        actionButton.setImage(nil, for: .normal)
        actionButton.isHidden = false
        isMineState = false
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        [profileImageView, nameLabel, infoLabel, contentLabel, dateLabel, actionButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
        }
        
        infoLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
        }
        
        actionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(36)
            $0.size.equalTo(24)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalTo(actionButton.snp.leading).offset(-16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(6)
            $0.leading.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(18)
        }
    }
    
    private var isMineState: Bool = false
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
    @objc private func actionTapped() {
        if isMineState {
            onDeleteTap?()
        } else {
            onReportTap?()
        }
    }
    
    private func formatDate(_ isoString: String) -> String {
       
        let datePart = isoString.split(separator: "T").first ?? Substring(isoString)
        let components = datePart.split(separator: "-")
        
        guard components.count == 3 else { return isoString }
        
        let year = components[0].suffix(2)
        let month = components[1]
        let day = components[2]
        
        return "\(year).\(month).\(day)"
    }

    // 🔥 accessToken에서 memberId 추출
    private func getMyIdFromToken() -> Int? {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            return nil
        }

        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }

        var base64 = String(segments[1])

        // padding 보정
        let requiredLength = 4 * ((base64.count + 3) / 4)
        base64 = base64.padding(toLength: requiredLength, withPad: "=", startingAt: 0)

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String,
              let id = Int(sub) else {
            return nil
        }

        return id
    }

    public func configure(with data: MapReview) {
        nameLabel.text = data.name
        infoLabel.text = "\(data.grade)기 | \(data.department)"
        contentLabel.text = data.content
        dateLabel.text = formatDate(data.reviewedAt)

        if let url = URL(string: data.profileImageUrl) {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
            )
        } else {
            profileImageView.image = UIImage(named: "Profile", in: Bundle.module, compatibleWith: nil)
        }

        // 🔥 토큰 기반으로 내 리뷰 판단 (서버 isMine 안 내려오는 경우 대응)
        let myId = getMyIdFromToken()
        let isMine = (myId == data.memberId)
        isMineState = isMine

        print("myId:", myId as Any)
        print("review memberId:", data.memberId)
        print("isMine:", isMine)

        if isMine {
            actionButton.setImage(
                UIImage(named: "Trash", in: Bundle.module, compatibleWith: nil)?
                    .withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        } else {
            actionButton.setImage(
                UIImage(named: "Warning", in: Bundle.module, compatibleWith: nil)?
                    .withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }
    }

    public func setDeleteButtonHidden(_ hidden: Bool) {
        if isMineState {
            actionButton.isHidden = hidden
        }
    }

    public func setReportButtonHidden(_ hidden: Bool) {
        if !isMineState {
            actionButton.isHidden = hidden
        }
    }
}
