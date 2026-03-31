//
//  FilterBottomSheetVC.swift
//  Feature
//
//  Created by 김민선 on 3/23/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import Service
import SnapKit
import Then

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
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    private let bottomSheetView = UIView().then {
        $0.backgroundColor = .color.surface.color
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "필터"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 20, weight: .bold)
    }
    
    private lazy var closeButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        $0.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        $0.tintColor = .color.mainText.color
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func makeSectionLabel(title: String) -> UILabel {
        return UILabel().then {
            $0.font = .suit(size: 18, weight: .semibold)
            $0.text = title
            $0.textColor = .color.mainText.color
        }
    }
    
    // 섹션 버튼들
    private lazy var gradeLabel = makeSectionLabel(title: "학년")
    private lazy var grade1Button = BottomSheetButton(frame: .zero, title: "1학년")
    private lazy var grade2Button = BottomSheetButton(frame: .zero, title: "2학년")
    private lazy var grade3Button = BottomSheetButton(frame: .zero, title: "3학년")

    private lazy var roleLabel = makeSectionLabel(title: "역할")
    private lazy var studentButton = BottomSheetButton(frame: .zero, title: "학생")
    private lazy var adminButton = BottomSheetButton(frame: .zero, title: "학생회")
    private lazy var blackListButton = BottomSheetButton(frame: .zero, title: "외출 금지")
    
    private lazy var genderLabel = makeSectionLabel(title: "성별")
    private lazy var manButton = BottomSheetButton(frame: .zero, title: "남성")
    private lazy var womanButton = BottomSheetButton(frame: .zero, title: "여성")
    
    private lazy var majorLabel = makeSectionLabel(title: "학과")
    private lazy var swButton = BottomSheetButton(frame: .zero, title: "sw")
    private lazy var iotButton = BottomSheetButton(frame: .zero, title: "iot")
    private lazy var aiButton = BottomSheetButton(frame: .zero, title: "ai")
    
    private lazy var resetButton = ResetButton().then {
        $0.setTitle("필터 초기화", for: .normal)
        $0.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
    }
    
    @objc func closeButtonTapped() { self.dismiss(animated: true) }
    
    @objc func roleTapped(sender: BottomSheetButton) {
        [studentButton, adminButton, blackListButton].forEach { $0.isSelected = ($0 == sender) ? !sender.isSelected : false }
        let role = sender.isSelected ? (sender == studentButton ? "ROLE_STUDENT" : (sender == adminButton ? "ROLE_ADMIN" : nil)) : nil
        viewModel.setupAuthority(authority: role)
        if sender == blackListButton { viewModel.setupIsBlackList(isBlackList: sender.isSelected) }
        fetchData()
    }
    
    @objc func gradeButtonTappped(sender: BottomSheetButton) {
        [grade1Button, grade2Button, grade3Button].forEach { $0.isSelected = ($0 == sender) ? !sender.isSelected : false }
        let gradeMap: [BottomSheetButton: Int] = [grade1Button: 1, grade2Button: 2, grade3Button: 3]
        viewModel.setupGrade(grade: sender.isSelected ? gradeMap[sender] : nil)
        fetchData()
    }
    
    @objc func genderButtonTapped(sender: BottomSheetButton) {
        [manButton, womanButton].forEach { $0.isSelected = ($0 == sender) ? !sender.isSelected : false }
        let gender = sender.isSelected ? (sender == manButton ? "MAN" : "WOMAN") : nil
        viewModel.setupGender(gender: gender)
        fetchData()
    }

    @objc func majorButtonTapped(sender: BottomSheetButton) {
        [swButton, iotButton, aiButton].forEach { $0.isSelected = ($0 == sender) ? !sender.isSelected : false }
        let major = sender.isSelected ? (sender == swButton ? "SW_DEVELOPMENT" : (sender == iotButton ? "EMBEDDED_SOFTWARE" : "AI_SOFTWARE")) : nil
        viewModel.setupMajor(major: major)
        fetchData()
    }
    
    private func fetchData() {
        viewModel.serachStudent(searchString: nil) { self.studentManagementVC.userList = $0 }
    }
    
    @objc func resetButtonTapped() {
        [studentButton, adminButton, blackListButton, grade1Button, grade2Button, grade3Button, manButton, womanButton, swButton, iotButton, aiButton].forEach { $0.isSelected = false }
        viewModel.resetInfo()
        fetchData()
    }
    
    public override func addView() {
        view.addSubview(dimmedView)
        dimmedView.addSubview(bottomSheetView)
        [titleLabel, closeButton, gradeLabel, grade1Button, grade2Button, grade3Button, roleLabel, studentButton, adminButton, blackListButton, genderLabel, manButton, womanButton, majorLabel, swButton, iotButton, aiButton, resetButton].forEach { bottomSheetView.addSubview($0) }
        
        [studentButton, adminButton, blackListButton].forEach { $0.addTarget(self, action: #selector(roleTapped), for: .touchUpInside) }
        [grade1Button, grade2Button, grade3Button].forEach { $0.addTarget(self, action: #selector(gradeButtonTappped), for: .touchUpInside) }
        [manButton, womanButton].forEach { $0.addTarget(self, action: #selector(genderButtonTapped), for: .touchUpInside) }
        [swButton, iotButton, aiButton].forEach { $0.addTarget(self, action: #selector(majorButtonTapped), for: .touchUpInside) }
    }
    
    public override func setLayout() {
        dimmedView.snp.makeConstraints { $0.edges.equalToSuperview() }
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(view.frame.height * 0.73)
        }
        titleLabel.snp.makeConstraints { $0.leading.equalToSuperview().inset(24); $0.top.equalToSuperview().inset(32) }
        closeButton.snp.makeConstraints { $0.trailing.equalToSuperview().inset(24); $0.centerY.equalTo(titleLabel) }
        
        gradeLabel.snp.makeConstraints { $0.leading.equalToSuperview().inset(24); $0.top.equalTo(titleLabel.snp.bottom).offset(32) }
        grade1Button.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalTo(gradeLabel.snp.bottom).offset(12)
            $0.width.equalToSuperview().multipliedBy(0.28)
            $0.height.equalTo(48)
        }
        grade2Button.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.top.width.height.equalTo(grade1Button) }
        grade3Button.snp.makeConstraints { $0.trailing.equalToSuperview().inset(24); $0.top.width.height.equalTo(grade1Button) }
        
        roleLabel.snp.makeConstraints { $0.leading.equalTo(gradeLabel); $0.top.equalTo(grade1Button.snp.bottom).offset(24) }
        studentButton.snp.makeConstraints { $0.leading.width.height.equalTo(grade1Button); $0.top.equalTo(roleLabel.snp.bottom).offset(12) }
        adminButton.snp.makeConstraints { $0.centerX.width.height.equalTo(grade2Button); $0.top.equalTo(studentButton) }
        blackListButton.snp.makeConstraints { $0.trailing.width.height.equalTo(grade3Button); $0.top.equalTo(studentButton) }
        
        genderLabel.snp.makeConstraints { $0.leading.equalTo(gradeLabel); $0.top.equalTo(studentButton.snp.bottom).offset(24) }
        manButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalTo(genderLabel.snp.bottom).offset(12)
            $0.width.equalToSuperview().multipliedBy(0.43)
            $0.height.equalTo(48)
        }
        womanButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.width.height.equalTo(manButton)
        }
        
        majorLabel.snp.makeConstraints { $0.leading.equalTo(gradeLabel); $0.top.equalTo(manButton.snp.bottom).offset(24) }
        swButton.snp.makeConstraints { $0.leading.width.height.equalTo(grade1Button); $0.top.equalTo(majorLabel.snp.bottom).offset(12) }
        iotButton.snp.makeConstraints { $0.centerX.width.height.equalTo(grade2Button); $0.top.equalTo(swButton) }
        aiButton.snp.makeConstraints { $0.trailing.width.height.equalTo(grade3Button); $0.top.equalTo(swButton) }
        
        resetButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
