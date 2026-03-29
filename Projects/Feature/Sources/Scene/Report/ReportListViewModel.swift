//
//  ReportListViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//


import Foundation

struct MockReportData {
    let userName: String
    let grade: Int
    let classNum: Int
    let reportContent: String
    let shopName: String
    let date: String
    let status: String // 처리 전, 완료
}

public final class ReportListViewModel {
    
    // ViewController에서 사용할 데이터 배열
    var reports: [MockReportData] = []
    
    // 하드코딩 데이터를 로드하는 임시 메서드
    func loadMockData() {
        reports = [
            MockReportData(userName: "김민솔", grade: 8, classNum: 1, reportContent: "얘 나쁜말 했어요", shopName: "짬뽕관 광주송정선운점", date: "26.02.12 18:53:32", status: "처리전"),
            MockReportData(userName: "김민솔", grade: 8, classNum: 1, reportContent: "얘 나쁜말 했어요", shopName: "짬뽕관 광주송정선운점", date: "26.02.12 18:53:32", status: "처리 완료"),
            MockReportData(userName: "김민솔", grade: 8, classNum: 1, reportContent: "얘 나쁜말 했어요", shopName: "짬뽕관 광주송정선운점", date: "26.02.12 18:53:32", status: "처리 완료"),
            MockReportData(userName: "김민솔", grade: 8, classNum: 1, reportContent: "얘 나쁜말 했어요", shopName: "짬뽕관 광주송정선운점", date: "26.02.12 18:53:32", status: "처리 완료"),
            MockReportData(userName: "김민솔", grade: 8, classNum: 1, reportContent: "얘 나쁜말 했어요", shopName: "짬뽕관 광주송정선운점", date: "26.02.12 18:53:32", status: "처리 완료")
        ]
    }
}
