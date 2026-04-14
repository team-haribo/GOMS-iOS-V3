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
    public let deletedBy: Int?
    public let reportContent: String?
    public let reviewContent: String?
    public let placeName: String?

    enum CodingKeys: String, CodingKey {
        case reportId = "report_id"
        case reviewId = "review_id"
        case reviewerMemberId = "reviewer_member_id"
        case reviewerName = "reviewer_name"
        case reviewerGrade = "reviewer_grade"
        case reviewerDepartment = "reviewer_department"
        case reviewerProfileImageUrl = "reviewer_profile_image_url"
        case reportCreatedAt = "report_created_at"
        case reportStatus = "report_status"
        case deletedAt = "deleted_at"
        case deletedBy = "deleted_by"
        case reportContent = "report_content"
        case reviewContent = "review_content"
        case placeName = "place_name"
    }
}

public enum ReportStatusType: String, Codable {
    case pending = "PENDING"
    case resolved = "RESOLVED"
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
    }
}

public final class ReportListViewModel {
    private var allReports: [ReportData] = []
    public var reports: [ReportData] = []
    private let reportProvider = MoyaProvider<ReportServices>()
    
    public var filterStatus: String = "pending"
    
    public init() {}
    
    public func fetchReportList(completion: @escaping (Bool) -> Void) {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            completion(false)
            return
        }
        
        let authorization = "Bearer \(token)"
        
        reportProvider.request(.reportList(status: filterStatus, authorization: authorization)) { result in
            switch result {
            case let .success(response):
                if response.statusCode == 200 {
                    do {
                        let responseData = try JSONDecoder().decode(ReportListResponseDTO.self, from: response.data)
                        self.allReports = responseData.reports.map { ReportData(dto: $0) }
                        self.reports = self.allReports
                        completion(true)
                    } catch {
                        print("Decoding Error: \(error)")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            case .failure(let error):
                print("Network Error: \(error)")
                completion(false)
            }
        }
    }

    public func filterReports(with text: String) {
        if text.isEmpty {
            reports = allReports
        } else {
            reports = allReports.filter {
                $0.reviewerName.localizedCaseInsensitiveContains(text) ||
                $0.reportContent.localizedCaseInsensitiveContains(text)
            }
        }
    }

    public func filterReportsByStatus(status: ReportStatusType?) {
        guard let status = status else {
            self.reports = self.allReports
            return
        }
        self.reports = self.allReports.filter { $0.reportStatus == status }
    }
}
