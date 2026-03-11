//
//  CalendarBottomSheetVC.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

class CalendarBottomSheetVC: BaseViewController, UICalendarViewDelegate {
    
    // MARK: - Properties
    let viewModel = LetecomerViewModel()
    
    var latecomerListVC: LatecomerListViewController
        
    init(latecomerListVC: LatecomerListViewController) {
        self.latecomerListVC = latecomerListVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selectedDate: DateComponents? = nil
    
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
        $0.text = "날짜 선택"
        $0.textColor = .color.mainText.color
        $0.font = .suit(size: 19, weight: .bold)
    }
    
    private lazy var closeButton = UIButton().then {
        $0.setBackgroundImage(.image.cancelButton.image, for: .normal)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var calendarView = UICalendarView().then {
        $0.tintColor = .color.admin.color
        $0.wantsDateDecorations = true
    }
    
    // MARK: - Life Cycel
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setCalendar()
        reloadDateView(date: Date())
    }
    
    @objc func closeButtonTapped() {
        self.updateLatecomerList(self.viewModel.latecomerListDatas)
        self.dismiss(animated: false, completion: nil)
    }
    
    private func setCalendar() {
        calendarView.delegate = self
        
        let calendarSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = calendarSelection
    }
    
    func reloadDateView(date: Date?) {
        if date == nil { return }
        let calendar = Calendar.current
        calendarView.reloadDecorations(forDateComponents: [calendar.dateComponents([.day, .month, .year], from: date!)], animated: true)
    }
    
    // MARK: - Add View
    override func addView() {
        [titleLabel, closeButton, calendarView].forEach { bottomSheetView.addSubview($0) }
        dimmedView.addSubview(bottomSheetView)
        view.addSubview(dimmedView)
    }

    // MARK: - Layout
    override func setLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(bounds.height * 0.56)
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
        
        calendarView.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.04)
            $0.trailing.equalTo(-bounds.width * 0.04)
            $0.bottom.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
    }
}

extension CalendarBottomSheetVC: UICalendarSelectionSingleDateDelegate {
    func updateLatecomerList(_ newList: [LatecomerListData]) {
        self.latecomerListVC.latecomerList = newList
        DispatchQueue.main.async {
            self.latecomerListVC.lateListCollectionView.reloadData()
        }
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents else { return }
        
        selection.setSelected(dateComponents, animated: true)
        selectedDate = dateComponents
        reloadDateView(date: Calendar.current.date(from: dateComponents))
        
        if let selectedDate = Calendar.current.date(from: dateComponents) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko")
            formatter.dateFormat = "yyyy-MM-dd"
            viewModel.setupDate(date: formatter.string(from: selectedDate))
        
            formatter.dateFormat = "yyyy년 M월 d일 (E)"
            self.latecomerListVC.setDateString(date: formatter.string(from: selectedDate))
    
            viewModel.getLatecomerList { newList in
                DispatchQueue.main.async {
                    self.updateLatecomerList(newList)
                }
            }
        }
    }
}

