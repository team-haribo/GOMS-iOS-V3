//
//  ReportListViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

// MARK: - DTO
public struct ReportListResponseDTO: Codable {
    public let reports: [ReportResponseDTO]
}

public struct ReportResponseDTO: Codable {
    public let reportId: Int
    public let reviewId: Int
    public let reviewerMemberId: Int
    public let reviewerName: String
    public let reviewerGrade: Int
    public let reviewerDepartment: String
    public let reviewerProfileImageUrl: String?
    public let reportCreatedAt: String
    public let reportStatus: ReportStatusType
    public let deletedAt: String?
    public let deletedBy: String?
    
    // MARK: - 서버 반영 예정 필드
    public let reportContent: String? // 신고 사유
    public let reviewContent: String? // 리뷰 본문
    public let placeName: String?     // 가게 이름 
}

// MARK: - Enum
public enum ReportStatusType: String, Codable {
    case pending = "PENDING"     // 처리전
    case resolved = "RESOLVED"   // 처리 완료
    case rejected = "REJECTED"   // 기각
}

// MARK: - Model
public struct ReportData {
    public let reportId: Int
    public let reviewId: Int
    public let reviewerName: String
    public let reviewerGrade: Int
    public let reviewerDepartment: String
    public let reportCreatedAt: String
    public let reportStatus: ReportStatusType
    public let reportContent: String
    public let reviewContent: String // 상세 페이지용 필드 추가
    public let location: String      // UI에는 location(가게 이름)으로 사용
    
    public init(
        reportId: Int,
        reviewId: Int,
        reviewerName: String,
        reviewerGrade: Int,
        reviewerDepartment: String,
        reportCreatedAt: String,
        reportStatus: ReportStatusType,
        reportContent: String,
        reviewContent: String,
        location: String
    ) {
        self.reportId = reportId
        self.reviewId = reviewId
        self.reviewerName = reviewerName
        self.reviewerGrade = reviewerGrade
        self.reviewerDepartment = reviewerDepartment
        self.reportCreatedAt = reportCreatedAt
        self.reportStatus = reportStatus
        self.reportContent = reportContent
        self.reviewContent = reviewContent
        self.location = location
    }
}

// MARK: - ViewModel
public final class ReportListViewModel {
    public var reports: [ReportData] = []
    
    public init() {}
    
    public func loadMockData() {
        reports = [
            ReportData(reportId: 1, reviewId: 101, reviewerName: "김민솔", reviewerGrade: 1, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: .pending, reportContent: "얘 나쁜말 했어요", reviewContent: "개 맛없음.. 가지마셈 엿", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 2, reviewId: 102, reviewerName: "김민솔", reviewerGrade: 1, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: .rejected, reportContent: "리뷰가 너무 공격적이에요", reviewContent: "개 맛없음.. 가지마셈 엿", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 3, reviewId: 103, reviewerName: "김민솔", reviewerGrade: 1, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: .resolved, reportContent: "거짓 정보를 유포하고 있습니다", reviewContent: "개 맛없음.. 가지마셈 엿", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 4, reviewId: 104, reviewerName: "김민솔", reviewerGrade: 1, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: .resolved, reportContent: "부적절한 단어 사용", reviewContent: "개 맛없음.. 가지마셈 엿", location: "짬뽕관 광주송정선운점"),
            ReportData(reportId: 5, reviewId: 105, reviewerName: "김민솔", reviewerGrade: 1, reviewerDepartment: "SW", reportCreatedAt: "26.02.12 18:53:32", reportStatus: .resolved, reportContent: "도배성 리뷰", reviewContent: "개 맛없음.. 가지마셈 엿", location: "짬뽕관 광주송정선운점")
        ]
    }
}
