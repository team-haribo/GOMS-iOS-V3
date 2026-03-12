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
        $0.image = .image.gomsBasicProfile.image
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        $0.text = "테스트 사용자"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 18, weight: .bold)
    }
    
    let userGradeDepartment = UILabel().then {
        $0.text = "3기 | AI"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 14, weight: .medium)
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
    
    
    let alarmsettingButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.gomsPrimary.color
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(switchQROn(_:)), for: .valueChanged)
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
    
    let cameraNowOntoggleButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.gomsPrimary.color
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(switchQROn(_:)), for: .valueChanged)
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
    
    let clockToggleButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.gomsPrimary.color
        $0.tintColor = .color.sub2.color
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
    
    @objc func switchQROn(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isSwitchOn")
        
        let defaults = UserDefaults.standard
        let isSwitchOn = defaults.bool(forKey: "isSwitchOn")
    }
    
    @objc func switchClockOn(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isClockOn")
        
        let defaults = UserDefaults.standard
        
        let isClockOn = defaults.bool(forKey: "isClockOn")
        
        if let mainViewController = navigationController?.viewControllers.first(where: { $0 is MainViewController }) as? MainViewController {
            mainViewController.isClockOn = sender.isOn
        }
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
        case 1: savedTheme = .light
        case 2: savedTheme = .dark
        default: savedTheme = .unspecified
        }
        
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color.mainText.color,
            .font: UIFont.suit(size: 17, weight: .semibold)
        ]
        let attributedTitle = NSAttributedString(string: "로그아웃\n", attributes: titleAttributes)
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.color.mainText.color,
            .font: UIFont.suit(size: 13, weight: .regular)
        ]
        let attributedMessage = NSAttributedString(string: "로그아웃 하시겠습니까?", attributes: messageAttributes)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.profileViewModel.profileLogout { [weak self] success in
                if success {
                    let introVC = IntroViewController()
                    self?.navigationController?.pushViewController(introVC, animated: true)
                } else {
                    print("실패")
                }
            }
        }
        alertController.addAction(confirmAction)
        
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .color.gomsTheme.color
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func passwordResetPage() {
        let changPassword = ProfileChangRePasswordViewController()
        self.navigationController?.pushViewController(changPassword, animated: true)
    }
    
    func performLogout() {
        let alertController = UIAlertController(title: "로그아웃", message: "로그아웃하시겠습니까?", preferredStyle: .alert)
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
                            print("이미지 업로드 완료.")
                        case .failure(let error):
                            print("이미지 업로드 실패: \(error)")
                        }
                    } receiveValue: { response in
                        print("이미지 업로드 응답: \(response)")
                    }
                    .store(in: &cancellables)
            } else {
                print("이미지를 JPEG 데이터로 변환하는데 실패했습니다.")
            }
        } else {
            print("선택한 이미지를 가져오는데 실패했습니다.")
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


    public override func viewDidLoad() {
        super.viewDidLoad()
        applySavedTheme()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        profileViewModel.loadProfileInfo { success, authority in
            if success {
                print("완료")
            } else {
                print("Failed to load profile information.")
            }
        }

        let isSwitchOn = UserDefaults.standard.bool(forKey: "isSwitchOn")
        cameraNowOntoggleButton.isOn = isSwitchOn
        
        let isClockOn = UserDefaults.standard.bool(forKey: "isClockOn")
        clockToggleButton.isOn = isClockOn
        
        profileViewModel.$profileInfo.sink { [weak self] profileInfo in
            guard let profileInfo = profileInfo else { return }
            DispatchQueue.main.async {
                self?.userName.text = profileInfo.name
                self?.perceptionNum.text = String(describing: profileInfo.lateCount)
                
                let majorText: String
                switch profileInfo.major {
                case Major.sw.rawValue:
                    majorText = "SW"
                case Major.iot.rawValue:
                    majorText = "IoT"
                default:
                    majorText = "AI"
                }
                
                let finalText = "\(profileInfo.grade)기ㅣ\(majorText)"
                let profileUrlString = profileInfo.profileUrl ?? ""
                
                if let profileUrl = URL(string: profileUrlString) {
                    URLSession.shared.dataTask(with: profileUrl) { data, response, error in
                        if let error = error {
                            print("이미지 데이터를 가져오는 중 에러 발생: \(error)")
                            return
                        }
                        
                        if let imageData = data, let profileImage = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self?.userProfile.image = profileImage
                            }
                        }
                    }
                    .resume()
                }
                
                let uploadimage = profileInfo.profileUrl
                self?.userGradeDepartment.text = finalText
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
    }
    
    @objc func handleRefreshControl() {
        profileViewModel.loadProfileInfo { success, authority in
            if success {
                print("완료")
            } else {
                print("Failed to load profile information.")
            }
        }
        
        let offset = CGPoint(x: 0, y: 0)
        self.view.frame.origin.y += offset.y
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshControl.endRefreshing()
            self.view.frame.origin.y = 0
        }
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
            passwordResetButton,
            themeTopLine,
            themeBottomLine,
            alarmText,
            alarmDescription,
            alarmsettingButton,
            cameraNowOnText,
            cameraNowOnDescription,
            cameraNowOntoggleButton,
            clockText,
            clockDescription,
            clockToggleButton,
            logoutButton,
            themeChangText,
            themeChangRec,
            themeSettingImg,
            themeSettingText,
            themeChangLine,
            withdrawalButton
        ].forEach {
            self.view.addSubview($0)
        }
    }

    //Layout
    
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
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }

        themeBottomLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(cameraNowOnDescription.snp.bottom).offset(24)
        }

        themeChangText.snp.makeConstraints {
            $0.width.equalTo(93)
            $0.height.equalTo(28)
            $0.top.equalTo(themeTopLine.snp.top).offset(24)
            $0.leading.equalToSuperview().inset(28)
        }

        themeChangRec.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.leading.trailing.equalToSuperview().inset(20)
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
            $0.width.equalTo(184)
            $0.height.equalTo(28)
            $0.leading.equalToSuperview().inset(28)
            $0.top.equalTo(alarmDescription.snp.bottom).offset(25.5)
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
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.top.equalTo(themeBottomLine.snp.bottom).offset(24)
        }

        logoutButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.top.equalTo(passwordResetButton.snp.bottom).offset(0)
        }

        withdrawalButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.top.equalTo(logoutButton.snp.bottom)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
