import UIKit
import SnapKit
import Then

public final class MapReviewCell: UITableViewCell {
    static let identifier = "MapReviewCell"
    
    public var onDeleteTap: (() -> Void)?
    public var onReportTap: (() -> Void)?
    
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(named: "New_jeans", in: Bundle.module, compatibleWith: nil)
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
    
    public let reportButton = UIButton().then {
        $0.setImage(UIImage(named: "Warning", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
    }
    
    public let deleteButton = UIButton().then {
        $0.setImage(UIImage(named: "Trash", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .color.sub2.color
        $0.isHidden = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 셀 재사용 이슈 방지
    override public func prepareForReuse() {
        super.prepareForReuse()
        deleteButton.isHidden = true
        reportButton.isHidden = false
        onDeleteTap = nil
        onReportTap = nil
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        [profileImageView, nameLabel, infoLabel, contentLabel, dateLabel, reportButton, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18) // 고정 위치로 변경
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
        
        [reportButton, deleteButton].forEach {
            $0.snp.makeConstraints {
                $0.top.equalTo(nameLabel) // 버튼 위치도 상단으로 정렬
                $0.trailing.equalToSuperview().inset(24)
                $0.size.equalTo(24)
            }
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalTo(reportButton.snp.leading).offset(-16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(6)
            $0.leading.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(18)
        }
    }
    
    private func setupActions() {
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func reportTapped() { onReportTap?() }
    @objc private func deleteTapped() { onDeleteTap?() }
    
    public func configure(with data: MapReview) {
        nameLabel.text = data.name
        infoLabel.text = data.info
        contentLabel.text = data.content
        dateLabel.text = data.date
        
        // 이름 비교 대신 모델의 isMine 값을 사용
        deleteButton.isHidden = !data.isMine
        reportButton.isHidden = data.isMine
    }
}
