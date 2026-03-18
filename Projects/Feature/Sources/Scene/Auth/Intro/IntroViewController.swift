//
//  IntroViewController.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

public final class IntroViewController: BaseViewController {

    // MARK: - Properties
    let viewModel = AuthViewModel()

    // MARK: - Layout Constants
    private enum Layout {
        static let logoSize: CGFloat = 80

        static let titleTopToLogo: CGFloat = 12
        static let titleHeight: CGFloat = 32

        static let descTopToTitle: CGFloat = 24
        static let descHeight: CGFloat = 52
        static let descLineSpacing: CGFloat = 8

        static let sideInsetRatio: CGFloat = 0.05

        static let signInHeight: CGFloat = 44
        static let signInBottomToFirstText: CGFloat = -16

        static let firstTextHeight: CGFloat = 19
        static let firstTextBottomToSignUp: CGFloat = -2

        static let dividerHeight: CGFloat = 1
        static let dividerBottomToSignUp: CGFloat = -11.5
        static let dividerToTextSpacing: CGFloat = 4

        static let signUpHeight: CGFloat = 48
        static let signUpBottomRatio: CGFloat = 0.06
    }

    // MARK: - UI Components

    private let gomsLogoImageView = UIImageView().then {
        $0.image = UIImage(
            named: "GOMS",
            in: Bundle.module,
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)

        $0.tintColor = .color.gomsPrimary.color
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        let fullText = "월수 외출제 관리 서비스"
        let highlightText = "월수 외출제"

        $0.textAlignment = .center
        $0.font = .suit(size: 20, weight: .semibold)

        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .foregroundColor: UIColor.color.mainText.color
            ]
        )

        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes(
                [.foregroundColor: UIColor.color.gomsPrimary.color],
                range: nsRange
            )
        }

        $0.attributedText = attributed
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "GOMS로 간편하게\n월수 외출제를 이용해 보세요!"
        $0.numberOfLines = 2
        $0.setLineSpacing(spacing: Layout.descLineSpacing)
        $0.textAlignment = .center
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }

    private lazy var signInButton = GOMSButton(
        frame: CGRect(x: 0, y: 0, width: 0, height: 0),
        title: "로그인"
    ).then {
        $0.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        $0.titleLabel?.font = .suit(size: 16, weight: .medium)
    }

    private let signUpGuideLabel = UILabel().then {
        $0.text = "GOMS가 처음이라면?"
        $0.font = .suit(size: 12, weight: .medium)
        $0.textColor = .color.button.color
    }

    private lazy var signUpButton = UIButton().then {
        $0.setTitle("회원가입", for: .normal)
        $0.backgroundColor = .clear
        $0.titleLabel?.font = UIFont.suit(size: 16, weight: .semibold)
        $0.setTitleColor(.color.gomsPrimary.color, for: .normal)
        $0.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }

    private let leftDividerView = UIView()
    private let rightDividerView = UIView()

    // MARK: - Life Cycle

public override func viewDidLoad() {
    super.viewDidLoad()

    // Ensure pushed view controllers do not show "돌아가기" back title
    navigationItem.backButtonDisplayMode = .minimal

    configureDividerViews()
}

    // MARK: - Selectors

    @objc private func signInButtonTapped() {
        let signInVC = SignInViewController(viewModel: viewModel)
        navigationController?.pushViewController(signInVC, animated: true)
    }

    @objc private func signUpButtonTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    // MARK: - Add View

    public override func addView() {
        view.addSubviews(
            gomsLogoImageView,
            titleLabel,
            descriptionLabel,
            signInButton,
            leftDividerView,
            signUpGuideLabel,
            rightDividerView,
            signUpButton
        )
    }

    // MARK: - Layout

    public override func setLayout() {
        gomsLogoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(258)
            $0.width.height.equalTo(Layout.logoSize)
        }

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.titleHeight)
            $0.centerX.equalTo(bounds.width * 0.5)
            $0.top.equalTo(gomsLogoImageView.snp.bottom).offset(Layout.titleTopToLogo)
        }

        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.descHeight)
            $0.centerX.equalTo(bounds.width * 0.5)
            $0.top.equalTo(titleLabel.snp.bottom).offset(Layout.descTopToTitle)
        }

        signInButton.snp.makeConstraints {
            $0.height.equalTo(Layout.signInHeight)
            $0.leading.equalTo(bounds.width * Layout.sideInsetRatio)
            $0.trailing.equalTo(-bounds.width * Layout.sideInsetRatio)
            $0.bottom.equalTo(signUpGuideLabel.snp.top).offset(Layout.signInBottomToFirstText)
        }

        signUpGuideLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.firstTextHeight)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(signUpButton.snp.top).offset(Layout.firstTextBottomToSignUp)
        }

        leftDividerView.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * Layout.sideInsetRatio)
            $0.bottom.equalTo(signUpButton.snp.top).offset(Layout.dividerBottomToSignUp)
            $0.trailing.equalTo(signUpGuideLabel.snp.leading).offset(-Layout.dividerToTextSpacing)
            $0.height.equalTo(Layout.dividerHeight)
        }

        rightDividerView.snp.makeConstraints {
            $0.trailing.equalTo(-bounds.width * Layout.sideInsetRatio)
            $0.bottom.equalTo(signUpButton.snp.top).offset(Layout.dividerBottomToSignUp)
            $0.height.equalTo(Layout.dividerHeight)
            $0.leading.equalTo(signUpGuideLabel.snp.trailing).offset(Layout.dividerToTextSpacing)
        }

        signUpButton.snp.makeConstraints {
            $0.height.equalTo(Layout.signUpHeight)
            $0.bottom.equalTo(-bounds.height * Layout.signUpBottomRatio)
            $0.centerX.equalTo(bounds.width * 0.5)
        }
    }

    // MARK: - Private

    private func configureDividerViews() {
        let dark = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        let light = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)

        [leftDividerView, rightDividerView].forEach {
            $0.setDynamicBackgroundColor(darkModeColor: dark, lightModeColor: light)
        }
    }
}

// MARK: - UIView Helpers

private extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
