//
//  FilterBottomSheetVC.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class FilterBottomSheetVC: BaseViewController {
    
    // MARK: - Properties
    var userList: [UserData] = []
    
    let viewModel = StudentManagementViewModel()
    
    var studentManagementVC: StudentManagementViewController
            
    init(studentManagementVC: StudentManagementViewController) {
        self.studentManagementVC = studentManagementVC
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    }
    
    private let bottomSheetView = UIView().then {
        $0.setDynamicBackgroundColor(darkModeColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1), lightModeColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "필터"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 19, weight: .bold)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setBackgroundImage(.image.cancelButton.image, for: .normal)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private let roleLabel = UILabel().then {
        $0.font = .suit(size: 19, weight: .semibold)
        $0.text = "역할"
        $0.textColor = .color.mainText.color
    }
    
    private lazy var studentButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "학생").then {
        $0.addTarget(self, action: #selector(roleTapped), for: .touchUpInside)
    }
    
    private lazy var adminButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "학생회").then {
        $0.addTarget(self, action: #selector(roleTapped), for: .touchUpInside)
    }
    
    private lazy var blackListButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "외출금지").then {
        $0.addTarget(self, action: #selector(roleTapped), for: .touchUpInside)
    }
    
    private let gradeLabel = UILabel().then {
        $0.font = .suit(size: 19, weight: .semibold)
        $0.text = "학년"
        $0.textColor = .color.mainText.color
    }
    
    private lazy var grade1Button = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "1학년").then {
        $0.addTarget(self, action: #selector(gradeButtonTappped), for: .touchUpInside)
    }
    
    private lazy var grade2Button = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "2학년").then {
        $0.addTarget(self, action: #selector(gradeButtonTappped), for: .touchUpInside)
    }
    
    private lazy var grade3Button = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "3학년").then {
        $0.addTarget(self, action: #selector(gradeButtonTappped), for: .touchUpInside)
    }
    
    private let genderLabel = UILabel().then {
        $0.font = .suit(size: 19, weight: .semibold)
        $0.text = "성별"
        $0.textColor = .color.mainText.color
    }
    
    private lazy var manButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "남성").then {
        $0.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
    }
    
    private lazy var womanButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "여성").then {
        $0.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside)
    }
    
    private let majorLabel = UILabel().then {
        $0.font = .suit(size: 19, weight: .semibold)
        $0.text = "학과"
        $0.textColor = .color.mainText.color
    }
    
    private lazy var swButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "SW").then {
        $0.addTarget(self, action: #selector(majorButtonTapped), for: .touchUpInside)
    }
    
    private lazy var iotButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "IoT").then {
        $0.addTarget(self, action: #selector(majorButtonTapped), for: .touchUpInside)
    }
    
    private lazy var aiButton = BottomSheetButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0), title: "AI").then {
        $0.addTarget(self, action: #selector(majorButtonTapped), for: .touchUpInside)
    }
    
    private lazy var resetButton = ResetButton().then {
        $0.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Life Cycel
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateUserList(_ newList: [UserData]) {
        self.studentManagementVC.userList = newList
        DispatchQueue.main.async {
            self.studentManagementVC.studentCollectionView.reloadData()
        }
    }
    
    // MARK: - Selectors
    @objc func closeButtonTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func roleTapped(sender: BottomSheetButton) {
        guard let role = sender.title(for: .normal) else { return }
        
        switch role {
        case "학생":
            studentButton.isSelected.toggle()
            adminButton.isSelected = false
            blackListButton.isSelected = false
            if studentButton.isSelected == true {
                viewModel.setupAuthority(authority: Authority.student.rawValue)
            }
        case "학생회":
            studentButton.isSelected = false
            adminButton.isSelected.toggle()
            blackListButton.isSelected = false
            if adminButton.isSelected == true {
                viewModel.setupAuthority(authority: Authority.admin.rawValue)
            }
        case "외출금지":
            studentButton.isSelected = false
            adminButton.isSelected = false
            blackListButton.isSelected.toggle()
            if blackListButton.isSelected == true {
                viewModel.setupIsBlackList(isBlackList: true)
            }
        default:
            break
        }
        
        viewModel.serachStudent(searchString: nil) { newList in
            DispatchQueue.main.async {
                self.updateUserList(newList)
            }
        }
    }
    
    @objc func gradeButtonTappped(sender: BottomSheetButton) {
        guard let grade = sender.title(for: .normal) else { return }
        
        switch grade {
        case "1학년":
            grade1Button.isSelected.toggle()
            grade2Button.isSelected = false
            grade3Button.isSelected = false
            if grade1Button.isSelected == true {
                viewModel.setupGrade(grade: 9)
            }
            
        case "2학년":
            grade1Button.isSelected = false
            grade2Button.isSelected.toggle()
            grade3Button.isSelected = false
            if grade2Button.isSelected == true {
                viewModel.setupGrade(grade: 8)
            }
        case "3학년":
            grade1Button.isSelected = false
            grade2Button.isSelected = false
            grade3Button.isSelected.toggle()
            if grade3Button.isSelected == true {
                viewModel.setupGrade(grade: 7)
            }
        default:
            break
        }
        
        viewModel.serachStudent(searchString: nil) { newList in
            self.updateUserList(newList)
        }
    }
    
    @objc func genderButtonTapped(sender: BottomSheetButton) {
        guard let gender = sender.title(for: .normal) else { return }
        
        switch gender {
        case "남성":
            manButton.isSelected.toggle()
            womanButton.isSelected = false
            if manButton.isSelected == true {
                viewModel.setupGender(gender: Gender.man.rawValue)
            }
        case "여성":
            manButton.isSelected = false
            womanButton.isSelected.toggle()
            if womanButton.isSelected == true {
                viewModel.setupGender(gender: Gender.woman.rawValue)
            }
        default:
            break
        }
        
        viewModel.serachStudent(searchString: nil) { newList in
            self.updateUserList(newList)
        }
    }

    @objc func majorButtonTapped(sender: BottomSheetButton) {
        guard let major = sender.title(for: .normal) else { return }
        
        switch major {
        case "SW":
            swButton.isSelected.toggle()
            iotButton.isSelected = false
            aiButton.isSelected = false
            if swButton.isSelected == true {
                viewModel.setupMajor(major: Major.sw.rawValue)
            }
        case "IoT":
            swButton.isSelected = false
            iotButton.isSelected.toggle()
            aiButton.isSelected = false
            if iotButton.isSelected == true {
                viewModel.setupMajor(major: Major.iot.rawValue)
            }
        case "AI":
            swButton.isSelected = false
            iotButton.isSelected = false
            aiButton.isSelected.toggle()
            if aiButton.isSelected == true {
                viewModel.setupMajor(major: Major.ai.rawValue)
            }
        default:
            break
        }
        
        viewModel.serachStudent(searchString: nil) { newList in
            self.updateUserList(newList)
        }
    }
    
    @objc func resetButtonTapped() {
        let buttons: [BottomSheetButton] = [
            studentButton, adminButton, blackListButton,
            grade1Button, grade2Button, grade3Button,
            manButton, womanButton, swButton,
            iotButton, aiButton
        ]

        for button in buttons {
            button.isSelected = false
        }
        
        viewModel.resetInfo()
        viewModel.serachStudent(searchString: nil) { newList in
            self.updateUserList(newList)
        }
    }
    
    // MARK: - Add View
    public override func addView() {
        [titleLabel, closeButton, roleLabel, studentButton, adminButton, blackListButton, gradeLabel, grade1Button, grade2Button, grade3Button, genderLabel, manButton, womanButton, majorLabel, swButton, iotButton, aiButton, resetButton].forEach { self.bottomSheetView.addSubview($0) }
        dimmedView.addSubview(bottomSheetView)
        view.addSubview(dimmedView)
    }
    
    // MARK:  - Layout
    public override func setLayout() {
        dimmedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(bounds.height * 0.8)
            $0.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
            $0.top.equalToSuperview().inset(16)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalTo(-bounds.width * 0.06)
            $0.top.equalToSuperview().inset(20)
        }
        
        roleLabel.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        studentButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.width.equalTo(bounds.width * 0.27)
            $0.height.equalTo(56)
            $0.top.equalTo(roleLabel.snp.bottom).offset(8)
        }
        
        adminButton.snp.makeConstraints {
            $0.width.equalTo(bounds.width * 0.27)
            $0.top.equalTo(roleLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.centerX.equalToSuperview()
        }
        
        blackListButton.snp.makeConstraints {
            $0.width.equalTo(bounds.width * 0.27)
            $0.top.equalTo(roleLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.trailing.equalTo(-bounds.width * 0.05)
        }
        
        gradeLabel.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
            $0.top.equalTo(studentButton.snp.bottom).offset(16)
        }
        
        grade1Button.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.width.equalTo(bounds.width * 0.27)
            $0.height.equalTo(56)
            $0.top.equalTo(gradeLabel.snp.bottom).offset(8)
        }
        
        grade2Button.snp.makeConstraints {
            $0.width.equalTo(bounds.width * 0.27)
            $0.top.equalTo(gradeLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.centerX.equalToSuperview()
        }
        
        grade3Button.snp.makeConstraints {
            $0.width.equalTo(bounds.width * 0.27)
            $0.top.equalTo(gradeLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.trailing.equalTo(-bounds.width * 0.05)
        }
        
        genderLabel.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
            $0.top.equalTo(grade1Button.snp.bottom).offset(16)
        }
        
        manButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.top.equalTo(genderLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.width.equalTo(bounds.width * 0.42)
        }
        
        womanButton.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(56)
            $0.width.equalTo(bounds.width * 0.42)
        }
        
        majorLabel.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.height.equalTo(32)
            $0.top.equalTo(manButton.snp.bottom).offset(16)
        }
        
        swButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.width.equalTo(bounds.width * 0.27)
            $0.height.equalTo(56)
            $0.top.equalTo(majorLabel.snp.bottom).offset(8)
        }
        
        iotButton.snp.makeConstraints {
            $0.width.equalTo(bounds.width * 0.27)
            $0.top.equalTo(majorLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.centerX.equalToSuperview()
        }
        
        aiButton.snp.makeConstraints {
            $0.width.equalTo(bounds.width * 0.27)
            $0.top.equalTo(majorLabel.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.trailing.equalTo(-bounds.width * 0.05)
        }
        
        resetButton.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(56)
            $0.bottom.equalTo(-bounds.height * 0.07)
        }
    }
}
