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
    case pending
    case completed
}

public final class ReportListViewModel {
    private var allReports: [ReportData] = []
    public var reports: [ReportData] = []
    private let reportProvider = MoyaProvider<ReportServices>()
    
    public var filterType: ReportFilterType = .pending
    
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
        
        // 1. pending 요청
        group.enter()
        reportProvider.request(.reportPending(authorization: authorization)) { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                print("🔥 [RAW PENDING RESPONSE]:", String(data: response.data, encoding: .utf8) ?? "nil")
                if let decoded = try? JSONDecoder().decode(ReportListResponseDTO.self, from: response.data) {
                    pendingReports = decoded.reports.map { ReportData(dto: $0) }
                    print("🔥 pending API count:", pendingReports.count)
                    print("🔥 pending full:", decoded.reports)
                    print("🔥 pending status:", decoded.reports.map { $0.reportStatus.rawValue })
                }
            case .failure:
                break
            }
        }
        
        // 2. resolved 요청
        group.enter()
        reportProvider.request(.reportResolved(authorization: authorization)) { result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                print("🔥 [RAW RESOLVED RESPONSE]:", String(data: response.data, encoding: .utf8) ?? "nil")
                if let decoded = try? JSONDecoder().decode(ReportListResponseDTO.self, from: response.data) {
                    resolvedReports = decoded.reports.map { ReportData(dto: $0) }
                    print("🔥 resolved API count:", resolvedReports.count)
                    print("🔥 resolved full:", decoded.reports)
                    print("🔥 resolved status:", decoded.reports.map { $0.reportStatus.rawValue })
                }
            case .failure:
                break
            }
        }
        
        // 3. 합치고 필터 적용
        group.notify(queue: .main) {
            print("🔥 ===== FINAL MERGE DEBUG =====")
            print("🔥 pending:", pendingReports.map { $0.reportId })
            print("🔥 resolved:", resolvedReports.map { $0.reportId })
            print("🔥 resolved status:",
                  resolvedReports.map { $0.reportStatus.rawValue })
            print("🔥 current filter:", self.filterType)

            self.allReports = pendingReports + resolvedReports

            switch self.filterType {
            case .pending:
                self.reports = self.allReports.filter { $0.reportStatus == .pending }

            case .completed:
                self.reports = self.allReports.filter {
                    $0.reportStatus == .approved || $0.reportStatus == .rejected
                }
            }

            print("🔥 pending count:", pendingReports.count)
            print("🔥 resolved count:", resolvedReports.count)
            print("🔥 final count:", self.reports.count)
            print("🔥 reports:", self.reports.map { "\($0.reportId)-\($0.reportStatus.rawValue)" })
            print("🔥 ===== END DEBUG =====")

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
        print("🔥 [DeleteReview] request reviewId:", reviewId)
            switch result {
            case .success(let response):
                print("🔥 [DeleteReview] statusCode:", response.statusCode)
                print("🔥 [DeleteReview] raw body:", String(data: response.data, encoding: .utf8) ?? "nil")
                completion(response.statusCode == 200 || response.statusCode == 204)
            case .failure:
                print("❌ [DeleteReview] Network Error")
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
        print("🔥 [RejectReport] request reportId:", reportId)
            switch result {
            case .success(let response):
                print("🔥 [RejectReport] statusCode:", response.statusCode)
                print("🔥 [RejectReport] raw body:", String(data: response.data, encoding: .utf8) ?? "nil")
                completion(response.statusCode == 200 || response.statusCode == 204)
            case .failure:
                print("❌ [RejectReport] Network Error")
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
        
        print("🔥 [ResolveReport] request reportId:", reportId)
        
        reportProvider.request(.reportResolve(reportId: reportId, authorization: authorization)) { result in
            switch result {
            case .success(let response):
                print("🔥 [ResolveReport] statusCode:", response.statusCode)
                print("🔥 [ResolveReport] raw body:", String(data: response.data, encoding: .utf8) ?? "nil")
                completion(response.statusCode == 200 || response.statusCode == 204)
            case .failure(let error):
                print("❌ [ResolveReport] Network Error:", error)
                completion(false)
            }
        }
    }

    // MARK: - Local State Update (UI Sync)

    public func removeReport(reportId: Int) {
        // ❌ 이제 실제 삭제하지 않고 상태만 변경하도록 수정
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

        // 🔥 필터 상태에 따라 reports 재구성
        switch filterType {
        case .pending:
            reports = allReports.filter { $0.reportStatus == .pending }

        case .completed:
            reports = allReports.filter {
                $0.reportStatus == .approved || $0.reportStatus == .rejected
            }
        }
    }

    public func filterReports(with text: String) {
        let base: [ReportData]

        // 상태 필터 먼저 적용 (기본: pending)
        switch filterType {
        case .pending:
            base = allReports.filter { $0.reportStatus == .pending }

        case .completed:
            base = allReports.filter {
                $0.reportStatus == .approved || $0.reportStatus == .rejected
            }
        }

        // 검색 필터 적용
        if text.isEmpty {
            reports = base
        } else {
            reports = base.filter {
                $0.reviewerName.localizedCaseInsensitiveContains(text) ||
                $0.reportContent.localizedCaseInsensitiveContains(text)
            }
        }
    }
}
