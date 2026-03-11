//
//  AdminMenuDataList.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

final class AdminMenuDataList {
    
    private var adminMenuArray: [AdminMenu] = []
    
    func makeAdminMenuData() {
        adminMenuArray = [
            AdminMenu(icon: .image.qrIcon.image, title: "QR 생성"),
            AdminMenu(icon: .image.studentCouncilIcon.image, title: "학생 관리"),
            AdminMenu(icon: .image.outingStatusIcon.image, title: "외출 현황"),
            AdminMenu(icon: .image.lateIcon.image, title: "지각자 명단"),
<<<<<<< HEAD
            AdminMenu(icon: .image.satting.image, title: "개인 설정")
=======
            AdminMenu(icon: .image.settingIcon.image, title: "개인 설정")
>>>>>>> 50497c2 (✨ - feat :: [#32] Admin 메뉴 및 학생 관리 기능 구현)
        ]
    }
    
    func getAdminMenuData() -> [AdminMenu] {
        self.makeAdminMenuData()
        return adminMenuArray
    }
}
