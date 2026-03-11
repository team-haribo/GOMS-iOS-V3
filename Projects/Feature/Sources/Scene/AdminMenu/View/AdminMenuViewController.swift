//
//  AdminMenuViewController.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public class AdminMenuViewController: BaseViewController {
    
    // MARK: - Properties
    var adminDataList = AdminMenuDataList()
    
    private let topView = UIView().then {
        $0.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
    }
    
    lazy var adminMenuCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK:  - Life Cycel
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        adminDataList.makeAdminMenuData()
        setupCollectionView()
    }
    
    public override func configNavigation() {
        super.configNavigation()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "관리자 메뉴"
        navigationController?.navigationBar.tintColor = .color.admin.color
    }
    
    private func setupCollectionView() {
        self.adminMenuCollectionView.dataSource = self
        self.adminMenuCollectionView.delegate = self
        adminMenuCollectionView.register(AdminMenuCell.self, forCellWithReuseIdentifier: AdminMenuCell.identifier)
    }
    
    public override func setLayout() {
        [topView, adminMenuCollectionView].forEach { view.addSubview($0) }
        
        topView.snp.makeConstraints {
            $0.top.equalTo(bounds.height * 0.2)
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.height.equalTo(1)
        }
        
        adminMenuCollectionView.snp.makeConstraints {
            $0.leading.equalTo(bounds.width * 0.05)
            $0.trailing.equalTo(-bounds.width * 0.05)
            $0.top.equalTo(topView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: Extension
extension AdminMenuViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adminDataList.getAdminMenuData().count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = adminMenuCollectionView.dequeueReusableCell(withReuseIdentifier: AdminMenuCell.identifier, for: indexPath) as! AdminMenuCell
        
        cell.icon.image = adminDataList.getAdminMenuData()[indexPath.row].icon
        cell.title.text = adminDataList.getAdminMenuData()[indexPath.row].title
        
        return cell
    }
}

extension AdminMenuViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bounds.width * 0.9
        let height: CGFloat = 72
        return CGSize(width: width, height: height)
    }
}

extension AdminMenuViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMenu = adminDataList.getAdminMenuData()[indexPath.row]
        
        switch indexPath.row {
        case 0:
            let adminQRVC = AdminQRViewController()
            navigationController?.pushViewController(adminQRVC, animated: true)
        case 1:
            let studentManagementVC = StudentManagementViewController()
            navigationController?.pushViewController(studentManagementVC, animated: true)
        case 2:
            let outingVC = AdminOutingViewController()
            navigationController?.pushViewController(outingVC, animated: true)
        case 3:
            let lateVC = LatecomerListViewController()
            navigationController?.pushViewController(lateVC, animated: true)
        case 4:
            let profileVC = AdminProfileViewController()
            navigationController?.pushViewController(profileVC, animated: true)
        default:
            break
        }
    }
}
