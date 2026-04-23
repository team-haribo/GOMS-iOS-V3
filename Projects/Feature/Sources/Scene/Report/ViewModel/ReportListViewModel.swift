//
//  ReportListViewModel.swift
//  Feature
//
//  Created by 김민선 on 3/29/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

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
    public let reportContent: String?
    public let reviewContent: String?
    public let placeName: String?
}

public enum ReportStatusType: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"
}

public struct ReportData {
    public let reportId: Int
    public let reviewId: Int
    public let reviewerName: String
    public let reviewerGrade: Int
    public let reviewerDepartment: String
    public let reportCreatedAt: String
    public let reportStatus: ReportStatusType
    public let reportContent: String
    public let reviewContent: String
    public let location: String
    public let profileImageUrl: String?
    
    public init(dto: ReportResponseDTO) {
        self.reportId = dto.reportId
        self.reviewId = dto.reviewId
        self.reviewerName = dto.reviewerName
        self.reviewerGrade = dto.reviewerGrade
        self.reviewerDepartment = dto.reviewerDepartment
        self.reportCreatedAt = dto.reportCreatedAt
        self.reportStatus = dto.reportStatus
        self.reportContent = dto.reportContent ?? "신고 사유 없음"
        self.reviewContent = dto.reviewContent ?? "리뷰 본문이 없습니다."
        self.location = dto.placeName ?? "알 수 없는 장소"
        self.profileImageUrl = dto.reviewerProfileImageUrl
    }
}

public enum ReportFilterType {
    case all
    case pending
    case completed
}

public final class ReportListViewModel {
    private var allReports: [ReportData] = []
    public var reports: [ReportData] = []
    private let reportProvider = MoyaProvider<ReportServices>()
    
    public private(set) var currentFilterType: ReportFilterType = .all
    public private(set) var searchText: String = ""
    
    public init() {}
    
    public func fetchReportList(completion: @escaping (Bool) -> Void) {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            completion(false)
            return
        }
        
        let authorization = "Bearer \(token)"
        var pendingReports: [ReportData] = []
        var resolvedReports: [ReportData] = []
        let group = DispatchGroup()
        
        group.enter()
        reportProvider.request(.reportPending(authorization: authorization)) { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                if let decoded = try? JSONDecoder().decode(ReportListResponseDTO.self, from: response.data) {
                    pendingReports = decoded.reports.map { ReportData(dto: $0) }
                }
            case .failure:
                break
            }
        }
        
        group.enter()
        reportProvider.request(.reportResolved(authorization: authorization)) { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                if let decoded = try? JSONDecoder().decode(ReportListResponseDTO.self, from: response.data) {
                    resolvedReports = decoded.reports.map { ReportData(dto: $0) }
                }
            case .failure:
                break
            }
        }
        
        group.notify(queue: .main) {
            self.allReports = pendingReports + resolvedReports
            self.applyFilters(with: self.searchText)
            completion(true)
        }
    }

    public func deleteReview(reviewId: Int, completion: @escaping (Bool) -> Void) {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            completion(false)
            return
        }
        let authorization = "Bearer \(token)"
        
        reportProvider.request(.reportDelete(reviewId: reviewId, authorization: authorization)) { result in
            switch result {
            case .success(let response):
                completion(response.statusCode == 200 || response.statusCode == 204)
            case .failure:
                completion(false)
            }
        }
    }

    public func rejectReport(reportId: Int, completion: @escaping (Bool) -> Void) {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            completion(false)
            return
        }
        let authorization = "Bearer \(token)"
        
        reportProvider.request(.reportReject(reportId: reportId, authorization: authorization)) { result in
            switch result {
            case .success(let response):
                completion(response.statusCode == 200 || response.statusCode == 204)
            case .failure:
                completion(false)
            }
        }
    }

    public func resolveReport(reportId: Int, completion: @escaping (Bool) -> Void) {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            completion(false)
            return
        }
        let authorization = "Bearer \(token)"
        
        reportProvider.request(.reportResolve(reportId: reportId, authorization: authorization)) { result in
            switch result {
            case .success(let response):
                completion(response.statusCode == 200 || response.statusCode == 204)
            case .failure:
                completion(false)
            }
        }
    }

    public func removeReport(reportId: Int) {
        updateReportStatus(reportId: reportId, status: .approved)
    }

    public func updateReportStatus(reportId: Int, status: ReportStatusType) {
        allReports = allReports.map {
            if $0.reportId == reportId {
                return ReportData(
                    dto: ReportResponseDTO(
                        reportId: $0.reportId,
                        reviewId: $0.reviewId,
                        reviewerMemberId: 0,
                        reviewerName: $0.reviewerName,
                        reviewerGrade: $0.reviewerGrade,
                        reviewerDepartment: $0.reviewerDepartment,
                        reviewerProfileImageUrl: $0.profileImageUrl,
                        reportCreatedAt: $0.reportCreatedAt,
                        reportStatus: status,
                        deletedAt: nil,
                        deletedBy: nil,
                        reportContent: $0.reportContent,
                        reviewContent: $0.reviewContent,
                        placeName: $0.location
                    )
                )
            }
            return $0
        }
        
        applyFilters(with: searchText)
    }

    public func updateFilterType(_ type: ReportFilterType) {
        self.currentFilterType = type
        applyFilters(with: searchText)
    }

    public func filterReports(with text: String) {
        self.searchText = text
        applyFilters(with: text)
    }
    
    private func applyFilters(with text: String?) {
        let base: [ReportData]

        switch currentFilterType {
        case .all:
            base = allReports
        case .pending:
            base = allReports.filter { $0.reportStatus == .pending }
        case .completed:
            base = allReports.filter {
                $0.reportStatus == .approved || $0.reportStatus == .rejected
            }
        }

        if let text = text, !text.isEmpty {
            reports = base.filter {
                $0.reviewerName.localizedCaseInsensitiveContains(text) ||
                $0.reportContent.localizedCaseInsensitiveContains(text)
            }
        } else {
            reports = base
        }
    }
}
