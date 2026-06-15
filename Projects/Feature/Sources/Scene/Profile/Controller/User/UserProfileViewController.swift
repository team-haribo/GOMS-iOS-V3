//
//  UserProfileViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Combine
import Moya
import Service
import Kingfisher
import SnapKit
import Then

public class UserProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    let profileViewModel = ProfileViewModel()
    var cancellables = Set<AnyCancellable>()
    let refreshControl = UIRefreshControl()
    
    let logo = UIImageView().then {
        $0.image = UIImage(
            named: "graylogo",
            in: Bundle.module,
            compatibleWith: nil
        )
    }

    let userProfile = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage.image.gomsBasicProfile.image // 최초 기본 이미지 지정으로 깜빡임 방지
    }
    
    let userProfilePencil = UIButton().then {
        $0.setImage(.image.gomsProfilePencil.image, for: .normal)
        $0.addTarget(self, action: #selector(ShowActionSheetProfilImageChange), for: .touchUpInside)

        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    let userName = UILabel().then {
        $0.text = " "
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .bold)
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    
    let userGradeDepartment = UILabel().then {
        $0.text = " "
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .medium)
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    
    let perceptionCount = UILabel().then {
        $0.text = "지각 횟수"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    let perceptionNum = UILabel().then {
        $0.text = "\(0)"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 18, weight: .semibold)
    }
    
    let perceptionText = UILabel().then {
        $0.text = "번"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .semibold)
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
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.color.surface.color.cgColor
    }
    
    let themeChangLine = UIButton().then {
        $0.backgroundColor = .color.gomsDivider.color
        $0.layer.cornerRadius = 12
    }
    
    let themeSettingText = UILabel().then {
        $0.text = ""
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 16, weight: .regular)
    }
    
    let themeSettingImg = UIImageView().then {
        $0.image = .image.under.image
    }
    
    let cameraNowOnText = UILabel().then {
        $0.text = "카메라 바로 켜기"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let cameraNowOnDescription = UILabel().then {
        $0.text = "앱을 실행하면 즉시 카메라가 켜져요"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .regular)
        $0.numberOfLines = 0
    }
    
    let alarmsettingButton = GOMSSwitch().then {
        $0.onTintColor = .color.gomsPrimary.color
        $0.addTarget(self, action: #selector(switchAlarmOn(_:)), for: .valueChanged)
        $0.isOn = false
    }
    
    let alarmText = UILabel().then {
        $0.text = "외출제 푸쉬 알림"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let alarmDescription = UILabel().then {
        $0.text = "외출할 시간이 될 때마다 알려드려요"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .regular)
        $0.numberOfLines = 0
    }
    
    let cameraNowOntoggleButton = GOMSSwitch().then {
        $0.onTintColor = .color.gomsPrimary.color
        $0.addTarget(self, action: #selector(switchCameraOn(_:)), for: .valueChanged)
        $0.isOn = false
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
    
    let clockToggleButton = GOMSSwitch().then {
        $0.onTintColor = .color.gomsPrimary.color
        $0.addTarget(self, action: #selector(switchClockOn(_:)), for: .valueChanged)
        $0.isOn = false
    }
    
    lazy var passwordResetButton = ProfileButton(icon: .image.satting.image, title: "비밀번호 재설정").then {
        $0.addTarget(self, action: #selector(passwordResetPage), for: .touchUpInside)
    }
    
    lazy var logoutButton = ProfileButton(icon: .image.outing.image, title: "로그아웃").then {
        $0.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    lazy var withdrawalButton = ProfileButton(icon: .image.cancelUser.image, title: "회원탈퇴").then {
        $0.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    let borderView = UIView().then() {
        $0.backgroundColor = .color.gomsDivider.color
    }
    
    public init(initialProfile: ProfileResponse? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let initialProfile = initialProfile {
            self.profileViewModel.profileInfo = initialProfile
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func withdrawalButtonTapped() {
        GOMSAlert.show(
            in: self,
            title: "회원 탈퇴",
            message: "정말로 회원을 탈퇴하시겠습니까?",
            actionTitle: "회원 탈퇴",
            cancelTitle: "취소",
            isNegative: true,
            action: { [weak self] in
                let withdrawalVC = WithdrawalViewController()
                self?.navigationController?.pushViewController(withdrawalVC, animated: true)
            }
        )
    }
    
    @objc func switchAlarmOn(_ sender: GOMSSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isAlarmOn")
    }

    @objc func switchCameraOn(_ sender: GOMSSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isCameraOn")
    }
    
    @objc func switchClockOn(_ sender: GOMSSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isClockOn")
        NotificationCenter.default.post(name: Notification.Name("clockChanged"), object: nil)
    }
    
    @IBAction private func ShowActionSheetClick(_ sender: UIButton) {
        updateImage(isActionSheetShowing: true)

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .color.blue.color

        let darkAction = UIAlertAction(title: "다크(기본)", style: .default) { [weak self] _ in
            self?.setTheme(.dark, themeText: "다크(기본)")
        }

        let lightAction = UIAlertAction(title: "라이트", style: .default) { [weak self] _ in
            self?.setTheme(.light, themeText: "라이트")
        }

        let systemAction = UIAlertAction(title: "시스템 기본 설정", style: .default) { [weak self] _ in
            self?.setTheme(.unspecified, themeText: "시스템 기본 설정")
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        actionSheet.addAction(darkAction)
        actionSheet.addAction(lightAction)
        actionSheet.addAction(systemAction)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true)
    }

    private func applySavedTheme() {
        let savedThemeValue = UserDefaults.standard.integer(forKey: "selectedTheme")
        
        let savedTheme: UIUserInterfaceStyle
        switch savedThemeValue {
        case 1:
            savedTheme = .light
        case 2:
            savedTheme = .dark
        default:
            savedTheme = .unspecified
        }
        
        guard let window = UIApplication.shared.windows.first else { return }
        window.overrideUserInterfaceStyle = savedTheme
        updateThemeText()
    }
    
    private func setTheme(_ style: UIUserInterfaceStyle, themeText: String) {
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = style
            themeSettingText.text = themeText
            UserDefaults.standard.set(style.rawValue, forKey: "selectedTheme")
            UserDefaults.standard.set(themeText, forKey: "themeText")
        }
    }
    
    public func updateThemeText() {
        self.themeSettingText.text = UserDefaults.standard.string(forKey: "themeText") ?? "시스템 테마 설정"
    }
    
    @objc func logoutButtonTapped() {
        GOMSAlert.show(
            in: self,
            title: "로그아웃",
            message: "로그아웃 하시겠습니까?",
            actionTitle: "로그아웃",
            cancelTitle: "취소",
            isNegative: true,
            action: { [weak self] in
                self?.profileViewModel.profileLogout { success in
                    DispatchQueue.main.async {
                        if success {
                            let introVC = IntroViewController()
                            let nav = UINavigationController(rootViewController: introVC)
                            if let window = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first?.windows.first {
                                window.rootViewController = nav
                                window.makeKeyAndVisible()
                            }
                        } else {
                            print("로그아웃 실패")
                        }
                    }
                }
            }
        )
    }
    
    @objc func passwordResetPage() {
        let changPassword = ProfileChangRePasswordViewController()
        self.navigationController?.pushViewController(changPassword, animated: true)
    }
    
    func performLogout() {
        GOMSAlert.show(
            in: self,
            title: "로그아웃",
            message: "로그아웃하시겠습니까?",
            actionTitle: "확인",
            cancelTitle: "취소",
            action: { [weak self] in
                self?.profileViewModel.profileLogout { success in
                    DispatchQueue.main.async {
                        if success {
                            let introVC = IntroViewController()
                            let nav = UINavigationController(rootViewController: introVC)
                            if let window = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first?.windows.first {
                                window.rootViewController = nav
                                window.makeKeyAndVisible()
                            }
                        } else {
                            print("로그아웃 실패")
                        }
                    }
                }
            }
        )
    }
    
    @objc func updateImage(isActionSheetShowing: Bool) {
        if isActionSheetShowing {
            themeSettingImg.image = UIImage.image.gomsTopButton.image
        } else {
            themeSettingImg.image = UIImage.image.gomsBottomButton.image
        }
    }
    
    @objc func themaChang() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let nextMode: UIUserInterfaceStyle = isDarkMode ? .light : .dark
        overrideUserInterfaceStyle = nextMode
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func ShowActionSheetProfilImageChange(_ sender: UIButton) {
        updateImage(isActionSheetShowing: true)
        let actionSheet = UIAlertController(title: "프로필 사진 선택", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "갤러리에서 선택", style: .default, handler: { [weak self] (ACTION:UIAlertAction) in
            self?.presentGallery()
        }))
        actionSheet.addAction(UIAlertAction(title: "기본 프로필 사용", style: .default, handler: { [weak self] (ACTION:UIAlertAction) in
            guard let self = self else { return }
            self.profileViewModel.deleteProfileImage()
                .sink(receiveCompletion: { [weak self] _ in
                    self?.profileViewModel.loadProfileInfo { _, _ in }
                }, receiveValue: { _ in })
                .store(in: &self.cancellables)
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
            GOMSAlert.show(
                in: self,
                title: "알림",
                message: "사용할 수 있는 앨범이 없습니다.",
                actionTitle: "확인",
                cancelTitle: "",
                action: {}
            )
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            userProfile.image = selectedImage
            if let jpegData = selectedImage.jpegData(compressionQuality: 0.5) {
                // MARK: - 통신 트리거 및 데이터 새로고침 동기화
                profileViewModel.updateProfileImage(imageData: jpegData)
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished:
                            // 업로드 성공 후 유저 프로필 정보를 최신 상태로 새로고침
                            self?.profileViewModel.loadProfileInfo { _, _ in }
                        case .failure(let error):
                            print("이미지 PATCH 실패: \(error)")
                        }
                    } receiveValue: { [weak self] response in
                        if let url = URL(string: response.imageUrl) {
                            self?.userProfile.kf.setImage(with: url)
                        }
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        applySavedTheme()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        profileViewModel.loadProfileInfo { _, _ in }

        // 토글 버튼들의 초기 값 할답 (최초 1회만 고정 실행되도록 격리 유지)
        alarmsettingButton.isOn = UserDefaults.standard.bool(forKey: "isAlarmOn")
        cameraNowOntoggleButton.isOn = UserDefaults.standard.bool(forKey: "isCameraOn")
        clockToggleButton.isOn = UserDefaults.standard.bool(forKey: "isClockOn")
        
        profileViewModel.$profileInfo
            .compactMap { $0 } // nil 데이터는 스킵하여 불필요한 레이아웃 갱신 및 깜빡임 차단
            .sink { [weak self] profileInfo in
                DispatchQueue.main.async {
                    // 애니메이션 없이 데이터만 매끄럽게 변경하도록 처리하여 깜빡임 제거
                    UIView.performWithoutAnimation {
                        self?.userName.text = profileInfo.name
                        self?.perceptionNum.text = String(describing: profileInfo.lateCount)
                        
                        let majorText: String
                        switch profileInfo.department {
                        case Major.sw.rawValue:
                            majorText = "SW"
                        case Major.iot.rawValue:
                            majorText = "IoT"
                        default:
                            majorText = "AI"
                        }
                        
                        self?.userGradeDepartment.text = "\(profileInfo.grade)기 | \(majorText)"
                        
                        if let urlString = profileInfo.profileImageUrl, let url = URL(string: urlString) {
                            self?.userProfile.kf.setImage(
                                with: url,
                                placeholder: self?.userProfile.image,
                                options: [.transition(.none), .keepCurrentImageWhileLoading] // transition 무효화로 로딩 시 깜빡임 차단
                            )
                        } else {
                            self?.userProfile.image = UIImage.image.gomsBasicProfile.image
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        view.backgroundColor = .color.background.color
        imagePickerController.delegate = self
        configureRefreshControl()
    }
    
    func configureRefreshControl () {
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.gomsPrimary.color
        if let scrollView = self.view as? UIScrollView {
            scrollView.refreshControl = refreshControl
        }
    }
    
    @objc func handleRefreshControl() {
        profileViewModel.loadProfileInfo { _, _ in }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshControl.endRefreshing()
        }
    }
    
    public override func addView() {
        [
            logo, userProfile, userName, userGradeDepartment, perceptionCount, perceptionNum,
            perceptionText, userProfilePencil, passwordResetButton, themeTopLine, themeBottomLine,
            alarmText, alarmDescription, alarmsettingButton, cameraNowOnText, cameraNowOnDescription,
            cameraNowOntoggleButton, clockText, clockDescription, clockToggleButton, logoutButton,
            themeChangText, themeChangRec, themeSettingImg, themeSettingText, themeChangLine, withdrawalButton
        ].forEach { self.view.addSubview($0) }
    }
    
    public override func setLayout() {
        logo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(135)
            $0.height.equalTo(56)
        }
        userProfile.snp.makeConstraints {
            $0.width.equalTo(64)
            $0.height.equalTo(64)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(logo.snp.bottom).offset(16)
        }
        userProfilePencil.snp.makeConstraints {
            $0.top.equalTo(userGradeDepartment.snp.top)
            $0.trailing.equalTo(userProfile.snp.trailing)
        }
        userName.snp.makeConstraints {
            $0.leading.equalTo(userProfile.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(perceptionCount.snp.leading).offset(-8)
            $0.top.equalTo(userProfile.snp.top).offset(12)
        }
        userGradeDepartment.snp.makeConstraints {
            $0.leading.equalTo(userName.snp.leading)
            $0.top.equalTo(userName.snp.bottom).offset(4)
        }
        perceptionCount.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(userName.snp.top)
        }
        perceptionNum.snp.makeConstraints {
            $0.trailing.equalTo(perceptionText.snp.leading).inset(-1)
            $0.top.equalTo(perceptionCount.snp.bottom).offset(4)
        }
        perceptionText.snp.makeConstraints {
            $0.width.equalTo(17)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(perceptionCount.snp.bottom).offset(4)
        }
        themeTopLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalTo(userProfile.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        themeBottomLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(cameraNowOnDescription.snp.bottom).offset(24)
        }
        themeChangText.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(28)
            $0.top.equalTo(themeTopLine.snp.top).offset(24)
            $0.trailing.lessThanOrEqualTo(view.snp.trailing).offset(-28)
        }
        themeChangRec.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(themeChangText.snp.bottom).offset(8)
        }
        themeSettingText.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.top.equalTo(themeChangRec.snp.top).offset(18)
            $0.leading.equalTo(themeChangRec.snp.leading).offset(12)
            $0.trailing.lessThanOrEqualTo(themeSettingImg.snp.leading).offset(-8)
        }
        themeSettingImg.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.equalTo(themeChangRec.snp.top).offset(20)
            $0.trailing.equalToSuperview().inset(32)
        }
        clockText.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(28)
            $0.top.equalTo(themeChangRec.snp.bottom).offset(24)
        }
        clockDescription.snp.makeConstraints {
            $0.leading.equalTo(clockText.snp.leading)
            $0.trailing.lessThanOrEqualTo(clockToggleButton.snp.leading).offset(-8)
            $0.top.equalTo(clockText.snp.bottom).offset(4)
        }
        clockToggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(clockText)
        }
        alarmText.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(28)
            $0.top.equalTo(clockDescription.snp.bottom).offset(24)
        }
        alarmDescription.snp.makeConstraints {
            $0.leading.equalTo(alarmText.snp.leading)
            $0.trailing.lessThanOrEqualTo(alarmsettingButton.snp.leading).offset(-8)
            $0.top.equalTo(alarmText.snp.bottom).offset(4)
        }
        alarmsettingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(alarmText)
        }
        cameraNowOnText.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(28)
            $0.top.equalTo(alarmDescription.snp.bottom).offset(25.5)
            $0.trailing.lessThanOrEqualTo(cameraNowOntoggleButton.snp.leading).offset(-8)
        }
        cameraNowOnDescription.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(28)
            $0.trailing.lessThanOrEqualTo(cameraNowOntoggleButton.snp.leading).offset(-8)
            $0.top.equalTo(cameraNowOnText.snp.bottom).offset(4)
        }
        cameraNowOntoggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(cameraNowOnText)
        }
        passwordResetButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(themeBottomLine.snp.bottom).offset(24)
        }
        logoutButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(passwordResetButton.snp.bottom).offset(0)
        }
        withdrawalButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(logoutButton.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
