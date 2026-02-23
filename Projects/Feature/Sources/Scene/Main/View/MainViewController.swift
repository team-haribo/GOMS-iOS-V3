//
//  MainViewController.swift
//  Feature
//
//  Created by 새미 on 1/10/24.
//  Copyright © 2024 HARIBO. All rights reserved.
//

import UIKit

public final class MainViewController: BaseViewController {
    
    // MARK: - Properties
    private let profileView = UIView()
    
    let profileImageView = UIImageView()
    
    let nameLabel = UILabel().then {
        $0.text = "홍길동"
        $0.textColor = .white
        $0.font = UIFont.pretendard(size: 19, weight: .semibold)
    }
     
    let studentIDLabel = UILabel().then {
        $0.text = "1학년 5반 1번"
        $0.font = UIFont.pretendard(size: 16, weight: .regular)
    }
    
    let myOutingStatusLabel = UILabel().then {
        $0.text = "외출 대기 중"
        $0.font = UIFont.pretendard(size: 19, weight: .semibold)
    }
    
    private let latecomerView = UIView()
    
    private let latecomerLabel = UILabel().then {
        $0.text = "지각자 TOP 3"
        $0.textColor = .white
        $0.font = UIFont.pretendard(size: 24, weight: .bold)
    }
    
    private let outingStatusView = UIView()
    
    private let outingStatusLabel = UILabel().then {
        $0.text = "외출 현황"
        $0.textColor = .white
        $0.font = UIFont.pretendard(size: 24, weight: .bold)
    }
    
    private let moreOutingStatusButton = UIButton() 
    
    private let dividingLineView = UIView()
    
    let numberOfPeopleOutingLabel = UILabel().then {
        $0.text = "66명이 외출 중"
        $0.font = UIFont.pretendard(size: 16, weight: .regular)
    }
    
    private let QRButton = UIButton()
    
    // MARK: - Selectors

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let mapVC = MapViewController()
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // MARK: - Add View
    override func addView() {

    }
    
    // MARK: - Layout
    override func setLayout() {
 
    }
}
