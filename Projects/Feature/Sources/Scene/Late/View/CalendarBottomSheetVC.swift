//
//  CalendarBottomSheetVC.swift
//  Feature
//
//  Created by 김민선 on 4/21/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then

class CalendarBottomSheetVC: BaseViewController, UICalendarViewDelegate {
    
    let viewModel = LetecomerViewModel()
    var latecomerListVC: LatecomerListViewController
    var selectedDate: DateComponents? = nil
        
    init(latecomerListVC: LatecomerListViewController) {
        self.latecomerListVC = latecomerListVC
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
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "날짜 선택"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 19, weight: .bold)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(.image.cancelButton.image, for: .normal)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var calendarView = UICalendarView().then {
        $0.tintColor = .color.admin.color
        $0.wantsDateDecorations = true
        $0.calendar = Calendar(identifier: .gregorian)
        $0.locale = Locale(identifier: "ko_KR")
        $0.fontDesign = .rounded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCalendarAppearance(calendarView)
    }
    
    private func configureCalendarAppearance(_ baseView: UIView) {
        for view in baseView.subviews {
            if let label = view as? UILabel {
                label.font = .suit(size: 20, weight: .semibold)
                if label.textColor != .color.admin.color {
                    label.textColor = .color.mainText.color
                }
            }
            configureCalendarAppearance(view)
        }
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func setCalendar() {
        calendarView.delegate = self
        let calendarSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = calendarSelection
    }
    
    func reloadDateView(date: Date?) {
        guard let date = date else { return }
        let calendar = Calendar.current
        calendarView.reloadDecorations(forDateComponents: [calendar.dateComponents([.day, .month, .year], from: date)], animated: true)
    }
    
    override func addView() {
        view.addSubview(dimmedView)
        dimmedView.addSubview(bottomSheetView)
        [titleLabel, closeButton, calendarView].forEach { bottomSheetView.addSubview($0) }
    }

    override func setLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(view.bounds.height * 0.6)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(24)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(24)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
}

extension CalendarBottomSheetVC: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let selectedDate = Calendar.current.date(from: dateComponents) else { return }
        
        selection.setSelected(dateComponents, animated: true)
        self.selectedDate = dateComponents
        
        let apiFormatter = DateFormatter()
        apiFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = apiFormatter.string(from: selectedDate)
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "yyyy년 M월 d일 (E)"
        
        latecomerListVC.setDateString(date: displayFormatter.string(from: selectedDate))
        
        viewModel.setupDate(date: dateString)
        viewModel.getLatecomerList { [weak self] newList in
            self?.latecomerListVC.latecomerList = newList
            self?.dismiss(animated: true)
        }
    }
}
