//
//  FilterBottomSheetVC.swift
//  Feature
//
//  Created by 김민선 on 3/23/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Service

public final class FilterBottomSheetVC: BaseViewController {
    
    var userList: [UserData] = []
    private var viewModel: StudentManagementViewModel
    var studentManagementVC: StudentManagementViewController
                
    init(studentManagementVC: StudentManagementViewController, viewModel: StudentManagementViewModel) {
        self.studentManagementVC = studentManagementVC
        self.viewModel = viewModel
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
    private lazy var swButton = BottomSheetButton(frame: .zero, title: "SW")
    private lazy var iotButton = BottomSheetButton(frame: .zero, title: "iot")
    private lazy var aiButton = BottomSheetButton(frame: .zero, title: "ai")
    
    private lazy var resetButton = ResetButton().then {
        $0.setTitle("필터 초기화", for: .normal)
        $0.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
        
        grade1Button.isSelected = viewModel.grade == 10
        grade2Button.isSelected = viewModel.grade == 9
        grade3Button.isSelected = viewModel.grade == 8
        
        studentButton.isSelected = viewModel.authority == "ROLE_STUDENT"
        adminButton.isSelected = viewModel.authority == "ROLE_STUDENT_COUNCIL"
        blackListButton.isSelected = viewModel.status == "CANNOT_OUTING"
        
        manButton.isSelected = viewModel.gender == "MAN"
        womanButton.isSelected = viewModel.gender == "WOMAN"
        
        swButton.isSelected = viewModel.major == "SW_DEVELOP"
        iotButton.isSelected = viewModel.major == "SMART_IOT"
        aiButton.isSelected = viewModel.major == "AI_DEVELOP"
    }
    
    @objc func closeButtonTapped() { self.dismiss(animated: true) }
    
    @objc func roleTapped(sender: BottomSheetButton) {
        [studentButton, adminButton, blackListButton].forEach { $0.isSelected = ($0 == sender) ? !sender.isSelected : false }
        let role = sender.isSelected ? (sender == studentButton ? "ROLE_STUDENT" : (sender == adminButton ? "ROLE_STUDENT_COUNCIL" : nil)) : nil
        viewModel.setupAuthority(authority: role)
        
        if sender == blackListButton {
            viewModel.setupStatus(status: sender.isSelected ? "CANNOT_OUTING" : nil)
        } else {
            viewModel.setupStatus(status: nil)
        }
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
        var genderValue: Gender? = nil
        if manButton.isSelected {
            genderValue = .male
        } else if womanButton.isSelected {
            genderValue = .female
        }
        viewModel.setupGender(gender: genderValue?.rawValue)
        fetchData()
    }

    @objc func majorButtonTapped(sender: BottomSheetButton) {
        [swButton, iotButton, aiButton].forEach { $0.isSelected = ($0 == sender) ? !sender.isSelected : false }
        var majorValue: Major? = nil
        if sender.isSelected {
            if sender == swButton {
                majorValue = .sw
            } else if sender == iotButton {
                majorValue = .iot
            } else {
                majorValue = .ai
            }
        }
        viewModel.setupMajor(major: majorValue?.rawValue)
        fetchData()
    }

    private func fetchData() {
        viewModel.filterStudent { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.studentManagementVC.userList = self.viewModel.userListDatas
            }
        }
    }

    @objc func resetButtonTapped() {
        [studentButton, adminButton, blackListButton, grade1Button, grade2Button, grade3Button, manButton, womanButton, swButton, iotButton, aiButton].forEach { $0.isSelected = false }
        viewModel.resetInfo()
        viewModel.filterStudent { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.studentManagementVC.userList = self.viewModel.userListDatas
                self.dismiss(animated: true)
            }
        }
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
