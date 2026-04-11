//
//  PlaceServices.swift
//  Service
//
//  Created by 김민선 on 4/10/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum PlaceServices {
    case getRecommendedPlaces(authorization: String)           // 내가 추천한 장소 목록 조회
    case getRecommendedPlacesCount(authorization: String)      // 내 추천 장소 개수 조회
    case searchPlace(keyword: String, authorization: String)   // 장소 검색
    case getPlaceDetail(placeId: Int, authorization: String)   // 장소 상세 조회
    case getPlaceReviews(placeId: Int, authorization: String)  // 장소 리뷰 목록 조회
    case getPlaceReviewCount(placeId: Int, authorization: String) // 장소 리뷰 개수 조회
    case getHotPlaces(authorization: String)                   // 핫플레이스(최근 인기 장소) 조회
    case syncPlaces(authorization: String)                     // 장소 동기화
    case recommendPlace(placeId: Int, authorization: String)   // 장소 추천 (하트 클릭)
    case cancelRecommendPlace(placeId: Int, authorization: String) // 장소 추천 취소
    case writeReview(placeId: Int, content: String, authorization: String) // 리뷰 작성
    case deleteReview(reviewId: Int, authorization: String)    // 리뷰 삭제
}

extension PlaceServices: TargetType {

    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String else {
            fatalError("SchoolBaseURL을 찾을 수 없습니다")
        }
        guard let url = URL(string: urlString) else {
            fatalError("Invalid baseURL string: \(urlString)")
        }
        return url
    }

    public var path: String {
        switch self {
        case .getRecommendedPlaces:
            return "/api/v3/place/recommended"
        case .getRecommendedPlacesCount:
            return "/api/v3/place/recommended/count"
        case .searchPlace:
            return "/api/v3/place/search"
        case .getPlaceDetail(let placeId, _):
            return "/api/v3/place/\(placeId)"
        case .getPlaceReviews(let placeId, _):
            return "/api/v3/place/review/\(placeId)"
        case .getPlaceReviewCount(let placeId, _):
            return "/api/v3/place/review/count/\(placeId)"
        case .getHotPlaces:
            return "/api/v3/place/hot-place"
        case .syncPlaces:
            return "/api/v3/place/sync"
        case .recommendPlace(let placeId, _), .cancelRecommendPlace(let placeId, _):
            return "/api/v3/place/recommend/\(placeId)"
        case .writeReview(let placeId, _, _):
            return "/api/v3/review/\(placeId)"
        case .deleteReview(let reviewId, _):
            return "/api/v3/review/\(reviewId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .syncPlaces, .recommendPlace, .writeReview:
            return .post
        case .cancelRecommendPlace, .deleteReview:
            return .delete
        default:
            return .get
        }
    }

    public var sampleData: Data {
        return "@@".data(using: .utf8)!
    }

    public var task: Task {
        switch self {
        case let .searchPlace(keyword, _):
            return .requestParameters(
                parameters: ["keyword": keyword],
                encoding: URLEncoding.queryString
            )
        case let .writeReview(_, content, _):
            return .requestParameters(
                parameters: ["content": content],
                encoding: JSONEncoding.default
            )
        default:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        // 모든 요청에 Authorization 토큰을 포함하도록 수정
        var commonHeaders = ["Content-Type": "application/json"]
        
        switch self {
        case .getRecommendedPlaces(let auth),
             .getRecommendedPlacesCount(let auth),
             .searchPlace(_, let auth),
             .getPlaceDetail(_, let auth),
             .getPlaceReviews(_, let auth),
             .getPlaceReviewCount(_, let auth),
             .getHotPlaces(let auth),
             .syncPlaces(let auth),
             .recommendPlace(_, let auth),
             .cancelRecommendPlace(_, let auth),
             .writeReview(_, _, let auth),
             .deleteReview(_, let auth):
            commonHeaders["Authorization"] = auth
        }
        
        return commonHeaders
    }
}
