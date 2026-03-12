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

public class AdminProfileViewController: BaseViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    let profileViewModel = ProfileViewModel()
    var cancellables = Set<AnyCancellable>()
    let refreshControl = UIRefreshControl()
    
    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    let userName = UILabel().then {
        $0.text = ""
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 19, weight: .semibold)
    }
    
    let userGradeDepartment = UILabel().then {
        $0.text = ""
        $0.textColor = .color.gomsSecondary.color
        $0.font = .suit(size: 16, weight: .regular)
    }
    
    let perceptionCount = UILabel().then {
        $0.text = "지각 횟수"
        $0.textColor = .color.sub1.color
        $0.font = .suit(size: 16, weight: .medium)
    }
    
    let perceptionNum = UILabel().then {
        $0.text = "0"
        $0.textColor = .color.gomsNegative.color
        $0.font = .suit(size: 19, weight: .semibold)
    }
    
    let perceptionText = UILabel().then {
        $0.text = "번"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 19, weight: .semibold)
    }
    
    let themeTopLine = UIView().then {
        $0.backgroundColor = .color.gomsDivider.color
    }
    
    let themeBottomLine = UIView().then {
        $0.backgroundColor = .color.gomsDivider.color
    }
    
    let themeChangText = UILabel().then {
        $0.text = "앱 테마 설정"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let themeChangRec = UIButton().then {
        $0.backgroundColor = .color.gomsTheme.color
        $0.addTarget(self, action: #selector(ShowActionSheetClick), for: .touchUpInside)
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.color.gomsCoverDivider.color.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    let themeSettingText = UILabel().then {
        $0.text = ""
        $0.textColor = .color.gomsSecondary.color
        $0.font = .suit(size: 16, weight: .regular)
    }
    
    let themeSettingImg = UIImageView().then {
        $0.image = .image.gomsBottomButton.image
    }
    
    let clockText = UILabel().then {
        $0.text = "시계 나타내기"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 16, weight: .semibold)
    }
    
    let clockDescription = UILabel().then {
        $0.text = "프로필 카드에 초 단위의 시간을 나타내요"
        $0.textColor = .color.sub2.color
        $0.font = .suit(size: 12, weight: .regular)
    }
    
    let clockToggleButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.mainText.color
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
        $0.font = UIFont.suit(size: 12, weight: .regular)
        
    }
    
    let qrMakeOntoggleButton: UISwitch = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .color.mainText.color
        $0.tintColor = .color.sub2.color
        $0.addTarget(self, action: #selector(switchQRMake(_:)), for: .valueChanged)
        $0.isOn = false
    }
    
    lazy var passwordResetButton = ProfileButton(icon: .image.passwordReset.image, title: "비밀번호 재설정").then {
        $0.addTarget(self, action: #selector(passwordResetPage), for: .touchUpInside)
    }
    
    lazy var logoutButton = ProfileButton(icon: .image.outing.image, title: "로그아웃").then {
        $0.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    lazy var withdrawalButton = ProfileButton(icon: .image.withdrawal.image, title: "회원탈퇴").then {
        $0.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    let borderView = UIView().then() {
        $0.backgroundColor = .color.gomsDivider.color
    }
    
    @objc func switchQRMake(_ sender: UISwitch) {
        print("QR카메라 바로생성: \(sender.isOn ? "On" : "Off")")
        UserDefaults.standard.set(sender.isOn, forKey: "isSwitchMakeOn")
        
        let defaults = UserDefaults.standard
        
        let isSwitchMakeOn = defaults.bool(forKey: "isSwitchMakeOn")
    }
    
    @objc func switchClockOn(_ sender: UISwitch) {
        print("시계 나타내기: \(sender.isOn ? "On" : "Off")")
        UserDefaults.standard.set(sender.isOn, forKey: "isClockOn")
        
        let defaults = UserDefaults.standard
        
        let isClockOn = defaults.bool(forKey: "isClockOn")
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

        // iPad 대응: popover anchor 지정
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
        }

        self.present(actionSheet, animated: true, completion: nil)
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

    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(view.snp.height).priority(.low)
        }

        addView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        applySavedTheme()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        profileViewModel.loadProfileInfo { success, authority in
            if success {
                print("성공")
            } else {
                print("Failed to load profile information.")
            }
        }

        let isSwitchOn = UserDefaults.standard.bool(forKey: "isSwitchMakeOn")
        qrMakeOntoggleButton.isOn = isSwitchOn
        
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
        
        let backBarButtonItem = UIBarButtonItem(title: "돌아가기", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        imagePickerController.delegate = self
        
        configureRefreshControl()
    }
    
    // MARK: - Configure Navigation
    public override func configNavigation() {
        self.navigationController?.navigationBar.tintColor = .color.admin.color
    }
    
    func configureRefreshControl () {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .color.admin.color
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
            self.refreshControl.endRefreshing()
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

        // iPad 대응: popover anchor 지정
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
        view.addSubview(scrollView)

        [
            userProfile,
            userName,
            userGradeDepartment,
            perceptionCount,
            perceptionNum,
            perceptionText,
            userProfilePencil,
            clockText,
            clockDescription,
            clockToggleButton,
            qrMakeOnText,
            qrMakeOnDescription,
            qrMakeOntoggleButton,
            themeTopLine,
            themeBottomLine,
            logoutButton,
            themeChangText,
            themeChangRec,
            themeSettingText,
            themeSettingImg,
            borderView,
            logoutButton,
            withdrawalButton,
            passwordResetButton

        ].forEach {
            self.scrollView.addSubview($0)
        }
    }

    public override func setLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        userProfile.snp.makeConstraints {
            $0.width.equalTo(64)
            $0.height.equalTo(64)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
        }

        userProfilePencil.snp.makeConstraints {
            $0.top.equalTo(userGradeDepartment.snp.top)
            $0.trailing.equalTo(userProfile.snp.trailing)
        }

        userName.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(32)
            $0.leading.equalTo(userProfile.snp.trailing).offset(16)
            $0.top.equalTo(userProfile.snp.top)
        }

        userGradeDepartment.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.leading.equalTo(userName.snp.leading)
            $0.top.equalTo(userName.snp.bottom).offset(4)
        }

        perceptionCount.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(28)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(userName.snp.top).inset(0)
        }

        perceptionNum.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.trailing.equalTo(perceptionText.snp.leading).inset(-1)
            $0.top.equalTo(perceptionCount.snp.bottom).offset(4)
        }

        perceptionText.snp.makeConstraints {
            $0.width.equalTo(17)
            $0.height.equalTo(32)
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
            $0.top.equalTo(qrMakeOnDescription.snp.bottom).offset(24)
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
            $0.width.equalTo(184)
            $0.height.equalTo(28)
            $0.leading.equalToSuperview().inset(28)
            $0.top.equalTo(themeChangRec.snp.bottom).offset(25)
        }

        clockDescription.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(20)
            $0.leading.equalTo(clockText.snp.leading)
            $0.top.equalTo(clockText.snp.bottom)
        }

        clockToggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.top.equalTo(themeChangRec.snp.bottom).offset(32)
        }

        qrMakeOnText.snp.makeConstraints {
            $0.width.equalTo(184)
            $0.height.equalTo(28)
            $0.leading.equalTo(clockDescription.snp.leading)
            $0.top.equalTo(clockDescription.snp.bottom).offset(25)
        }

        qrMakeOnDescription.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(20)
            $0.leading.equalTo(qrMakeOnText.snp.leading)
            $0.top.equalTo(qrMakeOnText.snp.bottom)
        }

        qrMakeOntoggleButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.top.equalTo(clockDescription.snp.bottom).offset(35)
        }

        passwordResetButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(bounds.height * 0.08)
            $0.top.equalTo(themeBottomLine.snp.bottom).offset(bounds.height * 0.01)
        }

        logoutButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.height.equalTo(bounds.height * 0.08)
            $0.top.equalTo(passwordResetButton.snp.bottom)
        }

        withdrawalButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(bounds.height * 0.08)
            $0.top.equalTo(logoutButton.snp.bottom)
        }
    }
}
