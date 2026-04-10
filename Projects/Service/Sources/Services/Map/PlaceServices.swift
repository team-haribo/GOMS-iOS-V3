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
    case getRecommendedPlaces               // 내가 추천한 장소 목록 조회
    case getRecommendedPlacesCount          // 내 추천 장소 개수 조회
    case searchPlace(keyword: String)       // 장소 검색
    case getPlaceDetail(placeId: Int)       // 장소 상세 조회
    case getPlaceReviews(placeId: Int)      // 장소 리뷰 목록 조회
    case getPlaceReviewCount(placeId: Int)  // 장소 리뷰 개수 조회
    case getHotPlaces                       // 핫플레이스(최근 인기 장소) 조회
    case syncPlaces                         // 장소 동기화
    case recommendPlace(placeId: Int)       // 장소 추천 (하트 클릭)
    case cancelRecommendPlace(placeId: Int) // 장소 추천 취소
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
        case .getPlaceDetail(let placeId):
            return "/api/v3/place/\(placeId)"
        case .getPlaceReviews(let placeId):
            return "/api/v3/place/review/\(placeId)"
        case .getPlaceReviewCount(let placeId):
            return "/api/v3/place/review/count/\(placeId)"
        case .getHotPlaces:
            return "/api/v3/place/hot-place"
        case .syncPlaces:
            return "/api/v3/place/sync"
        case .recommendPlace(let placeId), .cancelRecommendPlace(let placeId):
            return "/api/v3/place/recommend/\(placeId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .syncPlaces, .recommendPlace:
            return .post
        case .cancelRecommendPlace:
            return .delete
        default:
            return .get
        }
    }

    public var sampleData: Data {
        Data()
    }

    public var task: Task {
        switch self {
        case let .searchPlace(keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        // 보통 인증이 필요한 API이므로 Content-Type만 기본으로 설정합니다.
        // 만약 별도의 토큰 처리가 필요하다면 프로젝트의 BaseService나 인터셉터를 확인해야 해요!
        return ["Content-Type": "application/json"]
    }
}
