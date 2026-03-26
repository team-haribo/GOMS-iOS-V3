
//
//  AdminProfileViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Combine
import Moya
import Service

private enum Layout {
    static let horizontal: CGFloat = 20
    static let sectionInset: CGFloat = 28
}

extension Layout {
    static let trailingPadding: CGFloat = 32
}

private enum UserDefaultsKey {
    static let theme = "selectedTheme"
    static let themeText = "themeText"
    static let isClockOn = "isClockOn"
    static let isSwitchMakeOn = "isSwitchMakeOn"
}

public class AdminProfileViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    let profileViewModel = ProfileViewModel()
    var cancellables = Set<AnyCancellable>()

    let logo = UIImageView().then {
        $0.image = UIImage(
            named: "graylogo",
            in: Bundle.module,
            compatibleWith: nil
        )
        $0.contentMode = .scaleAspectFit
    }


    let userProfile = UIImageView().then {
        $0.image = .image.gomsBasicProfile.image
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let userProfilePencil = UIButton().then {
        $0.setImage(.image.adminpencil.image, for: .normal)
        $0.addTarget(self, action: #selector(ShowActionSheetProfilImageChange), for: .touchUpInside)

        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
  
     
        $0.clipsToBounds = false
    }
    
    let userName = UILabel().then {
        $0.text = "김준표"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .bold)
    }
    
    let userGradeDepartment = UILabel().then {
        $0.text = "9기 | IoT"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .medium)
    }
    
    let perceptionCount = UILabel().then {
        $0.text = "지각 횟수"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    let perceptionNum = UILabel().then {
        $0.text = "0"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    let perceptionText = UILabel().then {
        $0.text = "번"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    let profileBottomLine = UIView().then {
        $0.backgroundColor = .color.button.color
    }
    
    let themeTopLine = UIView().then {
        $0.backgroundColor = .color.button.color
    }
    
    let themeBottomLine = UIView().then {
        $0.backgroundColor = .color.button.color
    }
    
    let themeChangText = UILabel().then {
        $0.text = "앱 테마 설정"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let themeChangRec = UIButton().then {
        $0.backgroundColor = .color.gomsTheme.color
        $0.addTarget(self, action: #selector(ShowActionSheetClick), for: .touchUpInside)
        $0.layer.cornerRadius = 8
    }
    
    let themeSettingText = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .regular)
    }
    
    let themeSettingImg = UIImageView().then {
        let image = UIImage.image.under.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .color.button.color
    }
    
    let clockText = UILabel().then {
        $0.text = "시계 나타내기"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let clockDescription = UILabel().then {
        $0.text = "프로필 카드에 초 단위의 시간을 나타내요"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .regular)
        $0.numberOfLines = 0
    }
    
    let clockToggleButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.admin.color
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(switchClockOn(_:)), for: .valueChanged)
        $0.isOn = false
    }
    
    let qrMakeOnText = UILabel().then {
        $0.text = "QR 생성 바로 켜기"
        $0.textColor = .color.mainText.color
        $0.font = UIFont.suit(size: 16, weight: .semibold)
    }
    
    let qrMakeOnDescription = UILabel().then {
        $0.text = "앱을 실행하면 즉시 QR코드를 생성해요"
        $0.textColor = .color.sub2.color
        $0.font = UIFont.suit(size: 14, weight: .regular)
        $0.numberOfLines = 0
    }
    
    let qrMakeOntoggleButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.admin.color
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(switchQRMake(_:)), for: .valueChanged)
        $0.isOn = false
    }

    private lazy var passwordResetButton = ProfileButton(icon: .image.satting.image, title: "비밀번호 재설정").then {
        $0.addTarget(self, action: #selector(passwordResetPage), for: .touchUpInside)
    }

    private lazy var logoutButton = ProfileButton(icon: .image.outing.image, title: "로그아웃").then {
        $0.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    private lazy var withdrawalButton = ProfileButton(icon: .image.cancelUser.image, title: "회원탈퇴").then {
        $0.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    
    let borderView = UIView().then() {
        $0.backgroundColor = .color.button.color
    }
    
    @objc func switchQRMake(_ sender: UISwitch) {
        print("QR카메라 바로생성: \(sender.isOn ? "On" : "Off")")
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKey.isSwitchMakeOn)
    }
    
    @objc func switchClockOn(_ sender: UISwitch) {
        print("시계 나타내기: \(sender.isOn ? "On" : "Off")")
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKey.isClockOn)
        if let mainViewController = navigationController?.viewControllers.first(where: { $0 is AdminMainViewController  }) as? AdminMainViewController {
            mainViewController.isClockOn = sender.isOn
        }
    }
    
    @IBAction private func ShowActionSheetClick(_ sender: UIButton) {
        updateImage(isActionSheetShowing: true)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "다크(기본)", style: .default, handler: { [weak self] _ in
            self?.setTheme(.dark, themeText: "다크(기본)")
            self?.updateImage(isActionSheetShowing: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "라이트", style: .default, handler: { [weak self] _ in
            self?.setTheme(.light, themeText: "라이트")
            self?.updateImage(isActionSheetShowing: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "시스템 테마 설정", style: .default, handler: { [weak self] _ in
            self?.setTheme(.unspecified, themeText: "시스템 테마 설정")
            self?.updateImage(isActionSheetShowing: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { [weak self] _ in
            self?.updateImage(isActionSheetShowing: false)
        }))

        //ipad 반응형임
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
        }

        self.present(actionSheet, animated: true, completion: nil)
    }

    
    private func applySavedTheme() {
        let savedThemeValue = UserDefaults.standard.integer(forKey: UserDefaultsKey.theme)
        let savedTheme: UIUserInterfaceStyle
        switch savedThemeValue {
        case 1: savedTheme = .light
        case 2: savedTheme = .dark
        default: savedTheme = .unspecified
        }
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else { return }
        window.overrideUserInterfaceStyle = savedTheme
        updateThemeText()
    }

    private func setTheme(_ style: UIUserInterfaceStyle, themeText: String) {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first {
            window.overrideUserInterfaceStyle = style
            themeSettingText.text = themeText
            UserDefaults.standard.set(style.rawValue, forKey: UserDefaultsKey.theme)
            UserDefaults.standard.set(themeText, forKey: UserDefaultsKey.themeText)
        }
    }
    
    public func updateThemeText() {
        self.themeSettingText.text = UserDefaults.standard.string(forKey: UserDefaultsKey.themeText) ?? "시스템 테마 설정"
    }
    
    @objc func withdrawalButtonTapped() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "정말로 회원을 탈퇴하시겠습니까?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let withdrawal = UIAlertAction(title: "회원 탈퇴", style: .destructive) { action in
            let withdrawalVC = WithdrawalViewController()
            self.navigationController?.pushViewController(withdrawalVC , animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(withdrawal)
        
        self.present(alert, animated: true)
    }
    
    @objc func logoutButtonTapped() {
        let alertController = UIAlertController(
            title: "로그아웃",
            message: "로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let confirmAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            
            let introVC = IntroViewController()
            let nav = UINavigationController(rootViewController: introVC)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }

        alertController.addAction(confirmAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
  
    
    @objc func updateImage(isActionSheetShowing: Bool) {
        if isActionSheetShowing {
            themeSettingImg.image = UIImage.image.gomsTopButton.image
        } else {
            themeSettingImg.image = UIImage.image.gomsBottomButton.image
        }
    }
    
    @objc func themeChange() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let nextMode: UIUserInterfaceStyle = isDarkMode ? .light : .dark
        overrideUserInterfaceStyle = nextMode
        setNeedsStatusBarAppearanceUpdate()
    }



    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        fetchData()
    }

    private func setupUI() {
        applySavedTheme()
        view.backgroundColor = .color.background.color
        navigationController?.navigationBar.prefersLargeTitles = false
        imagePickerController.delegate = self

        let isSwitchOn = UserDefaults.standard.bool(forKey: UserDefaultsKey.isSwitchMakeOn)
        qrMakeOntoggleButton.isOn = isSwitchOn

        let isClockOn = UserDefaults.standard.bool(forKey: UserDefaultsKey.isClockOn)
        clockToggleButton.isOn = isClockOn
    }

    private func bind() {
        profileViewModel.$profileInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profileInfo in
                guard let self = self, let profileInfo else { return }

                self.userName.text = profileInfo.name
                self.perceptionNum.text = "\(profileInfo.lateCount)"

                let majorText: String
                switch profileInfo.major {
                case Major.sw.rawValue:
                    majorText = "SW"
                case Major.iot.rawValue:
                    majorText = "IoT"
                default:
                    majorText = "AI"
                }

                self.userGradeDepartment.text = "\(profileInfo.grade)기 | \(majorText)"

                if let url = URL(string: profileInfo.profileUrl ?? "") {
                    self.userProfile.kf.setImage(
                        with: url,
                        placeholder: UIImage.image.gomsBasicProfile.image
                    )
                }
            }
            .store(in: &cancellables)
    }

    private func fetchData() {
        profileViewModel.loadProfileInfo { _, _ in }
    }

    
    // MARK: - Configure Navigation
    public override func configNavigation() {
        self.navigationController?.navigationBar.tintColor = .color.admin.color
    }
    
    
    @objc func handleRefreshControl() {
        profileViewModel.loadProfileInfo { success, authority in
            if success {
                print("성공")
            } else {
                print("Failed to load profile information.")
            }
        }
        
        let offset = CGPoint(x: 0, y: 0)
        self.view.frame.origin.y += offset.y
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func passwordResetPage() {
        let changPassword = ProfileChangRePasswordViewController()
        self.navigationController?.pushViewController(changPassword, animated: true)
    }
    
    @IBAction func ShowActionSheetProfilImageChange(_ sender: UIButton) {
        updateImage(isActionSheetShowing: true)
        let actionSheet = UIAlertController(title: "프로필 사진 선택", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "갤러리에서 선택", style: .default, handler: { [weak self] (ACTION:UIAlertAction) in
            self?.presentGallery()
        }))
        actionSheet.addAction(UIAlertAction(title: "기본 프로필 사용", style: .default, handler: { [weak self] (ACTION:UIAlertAction) in
            self?.userProfile.image = .image.gomsBasicProfile.image
            let viewModel = ProfileViewModel()
            viewModel.deleteProfileImage()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { [weak self] _ in
            self?.updateImage(isActionSheetShowing: false)
        }))

        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
        }

        self.present(actionSheet, animated: true, completion: nil)
    }
    func presentGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "알림", message: "사용할 수 있는 앨범이 없습니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            userProfile.image = selectedImage
            
            if let jpegData = selectedImage.jpegData(compressionQuality: 0.5) {
                profileViewModel.updateProfileImage(imageData: jpegData)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            print("Image upload finished.")
                        case .failure(let error):
                            print("Image upload failed with error: \(error)")
                        }
                    } receiveValue: { response in
                        print("Image upload response: \(response)")
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    public override func addView() {
        [
            logo,
            userProfile,
            userName,
            userGradeDepartment,
            perceptionCount,
            perceptionNum,
            perceptionText,
            userProfilePencil,

            themeTopLine,
            themeBottomLine,

            themeChangText,
            themeChangRec,
            themeSettingText,
            themeSettingImg,

            clockText,
            clockDescription,
            clockToggleButton,

            qrMakeOnText,
            qrMakeOnDescription,
            qrMakeOntoggleButton,

            passwordResetButton,
            logoutButton,
            withdrawalButton
        ].forEach {
            view.addSubview($0)
        }
        view.bringSubviewToFront(userProfilePencil)
        view.bringSubviewToFront(userName)
        view.bringSubviewToFront(userGradeDepartment)
    }

    public override func setLayout() {
        logo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().inset(Layout.horizontal)
            $0.width.equalTo(135)
            $0.height.equalTo(56)
        }
        userProfile.snp.makeConstraints {
            $0.width.equalTo(64)
            $0.height.equalTo(64)
            $0.leading.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(logo.snp.bottom).offset(16)
        }

        userProfilePencil.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.bottom.equalTo(userProfile.snp.bottom)
            $0.trailing.equalTo(userProfile.snp.trailing)
        }

        userName.snp.makeConstraints {
            $0.leading.equalTo(userProfile.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(perceptionCount.snp.leading).offset(-8)
            $0.top.equalTo(userProfile.snp.top).offset(12)
        }

        userGradeDepartment.snp.makeConstraints {
            $0.leading.equalTo(userName.snp.leading)
            $0.trailing.lessThanOrEqualToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(userName.snp.bottom).offset(4)
        }

        perceptionCount.snp.makeConstraints { // 지각횟수
            $0.trailing.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(userName.snp.top)
        }

        perceptionNum.snp.makeConstraints {
            $0.trailing.equalTo(perceptionText.snp.leading).inset(-1)
            $0.top.equalTo(perceptionCount.snp.bottom).offset(4)
        }

        perceptionText.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(perceptionCount.snp.bottom).offset(4)
        }

        passwordResetButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(themeBottomLine.snp.bottom).offset(24)
        }

        logoutButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(passwordResetButton.snp.bottom)
        }

        withdrawalButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(logoutButton.snp.bottom)
        }

        themeTopLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalTo(userProfile.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(Layout.horizontal)
            $0.trailing.equalToSuperview().inset(Layout.horizontal)
        }

        themeChangText.snp.makeConstraints {
            $0.width.equalTo(93)
            $0.height.equalTo(28)
            $0.top.equalTo(themeTopLine.snp.top).offset(24)
            $0.leading.equalToSuperview().inset(Layout.horizontal)
        }

        themeChangRec.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(themeChangText.snp.bottom).offset(8)
        }

        themeSettingText.snp.makeConstraints {
            $0.width.equalTo(106)
            $0.height.equalTo(28)
            $0.top.equalTo(themeChangRec.snp.top).offset(18)
            $0.leading.equalTo(themeChangRec.snp.leading).offset(12)
        }

        themeSettingImg.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.equalTo(themeChangRec.snp.top).offset(20)
            $0.trailing.equalToSuperview().inset(Layout.trailingPadding)
        }

        clockText.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(themeChangRec.snp.bottom).offset(24)
        }

        clockDescription.snp.makeConstraints {
            $0.leading.equalTo(clockText.snp.leading)
            $0.top.equalTo(clockText.snp.bottom).offset(4)
        }

        clockToggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontal)
            $0.centerY.equalTo(clockText)
        }

        qrMakeOnText.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(clockDescription.snp.bottom).offset(24)
        }

        qrMakeOnDescription.snp.makeConstraints {
            $0.leading.equalTo(qrMakeOnText.snp.leading)
            $0.top.equalTo(qrMakeOnText.snp.bottom).offset(4)
        }

        qrMakeOntoggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontal)
            $0.centerY.equalTo(qrMakeOnText)
        }

        themeBottomLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontal)
            $0.top.equalTo(qrMakeOnDescription.snp.bottom).offset(25)
        }




    }
}

