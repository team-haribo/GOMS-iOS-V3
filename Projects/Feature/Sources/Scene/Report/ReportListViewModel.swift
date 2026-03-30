//
//  ReportListViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct ReportData {
    public let reportId: Int
    public let reviewId: Int
    public let reviewerName: String
    public let reviewerGrade: Int
    public let reviewerDepartment: String
    public let reportCreatedAt: String
    public let reportStatus: String
    public let reportContent: String
    public let location: String
    
    public init(reportId: Int, reviewId: Int, reviewerName: String, reviewerGrade: Int, reviewerDepartment: String, reportCreatedAt: String, reportStatus: String, reportContent: String, location: String) {
        self.reportId = reportId
        self.reviewId = reviewId
        self.reviewerName = reviewerName
        self.reviewerGrade = reviewerGrade
        self.reviewerDepartment = reviewerDepartment
        self.reportCreatedAt = reportCreatedAt
        self.reportStatus = reportStatus
        self.reportContent = reportContent
        self.location = location
    }
}

public final class ReportListViewModel {
    public var reports: [ReportData] = []
    
    public init() {}
    
    public func loadMockData() {
        reports = [
            ReportData(reportId: 1, reviewId: 101, reviewerName: "김민솔", reviewerGrade: 8, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: "RECEIVED", reportContent: "얘 나쁜말 했어요", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 2, reviewId: 102, reviewerName: "김민솔", reviewerGrade: 8, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: "COMPLETED", reportContent: "리뷰가 너무 공격적이에요", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 3, reviewId: 103, reviewerName: "김민솔", reviewerGrade: 8, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: "COMPLETED", reportContent: "거짓 정보를 유포하고 있습니다", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 4, reviewId: 104, reviewerName: "김민솔", reviewerGrade: 8, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: "COMPLETED", reportContent: "부적절한 단어 사용", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 5, reviewId: 105, reviewerName: "김민솔", reviewerGrade: 8, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: "COMPLETED", reportContent: "도배성 리뷰", location: "짬뽕관 광주송정선운점")
        ]
    }
}
