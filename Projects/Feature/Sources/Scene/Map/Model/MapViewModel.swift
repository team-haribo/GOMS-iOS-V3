//
//  MapViewModel.swift
//  Feature
//
//  Created by 김준표 on 4/16/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya
import Service

public final class MapViewModel {

    // MARK: - Properties
    private let placeProvider = MoyaProvider<PlaceServices>()
    
    private var accessToken: String {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            return ""
        }
        return "Bearer \(token)"
    }

    // MARK: - Data
    public private(set) var allPlaces: [MapPlaceData] = []
    public private(set) var searchResults: [MapPlaceData] = []
    public private(set) var reviews: [MapReview] = []
    public private(set) var currentPlaceDetail: MapPlaceDetailModel?
    public private(set) var selectedPlaceId: Int = -1
    public private(set) var distanceText: String = ""
    public private(set) var timeText: String = ""
    public private(set) var hotPlaces: [MapPlaceData] = []
    public private(set) var recommendedPlaces: [MapPlaceData] = []

    // MARK: - Route Data
    public private(set) var routeResult: MapRouteModel?
    public var onRouteUpdated: (() -> Void)?

    // MARK: - Binding
    public var onPlacesUpdated: (() -> Void)?
    public var onSearchUpdated: (() -> Void)?
    public var onReviewsUpdated: (() -> Void)?
    public var onDetailUpdated: (() -> Void)?
    public var onError: ((String) -> Void)?
    public var onHotPlacesUpdated: (() -> Void)?
    public var onRecommendedPlacesUpdated: (() -> Void)?

    // MARK: - API

    public func fetchAllPlaces() {
        placeProvider.request(.getAllPlaces(authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MapPlaceResponse.self, from: response.data)
                    self?.allPlaces = decoded.places
                    self?.onPlacesUpdated?()
                } catch {
                    self?.onError?("장소 리스트 디코딩 실패")
                }
            case .failure:
                self?.onError?("장소 리스트 요청 실패")
            }
        }
    }

    public func fetchHotPlaces(days: Int = 7) {
        placeProvider.request(.getHotPlaces(days: days, authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MapPlaceResponse.self, from: response.data)
                    self?.hotPlaces = decoded.places
                    self?.onHotPlacesUpdated?()
                } catch {
                    self?.onError?("핫플레이스 디코딩 실패")
                }
            case .failure:
                self?.onError?("핫플레이스 요청 실패")
            }
        }
    }

    public func fetchRecommendedPlaces() {
        placeProvider.request(.getRecommendedPlaces(authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MapPlaceResponse.self, from: response.data)
                    self?.recommendedPlaces = decoded.places
                    self?.onRecommendedPlacesUpdated?()
                } catch {
                    self?.onError?("추천 장소 디코딩 실패")
                }
            case .failure:
                self?.onError?("추천 장소 요청 실패")
            }
        }
    }

    public func searchPlace(keyword: String) {
        placeProvider.request(.searchPlace(keyword: keyword, authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MapPlaceResponse.self, from: response.data)
                    self?.searchResults = decoded.places
                    self?.onSearchUpdated?()
                } catch {
                    self?.searchResults = []
                    self?.onError?("검색 디코딩 실패")
                    self?.onSearchUpdated?()
                }
            case .failure:
                self?.onError?("검색 실패")
            }
        }
    }

    public func fetchPlaceDetail(placeId: Int) {
        placeProvider.request(.getPlaceDetail(placeId: placeId, authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                if let decoded = try? JSONDecoder().decode(MapPlaceDetailModel.self, from: response.data) {
                    self?.currentPlaceDetail = decoded
                    self?.selectedPlaceId = decoded.placeId

                    // 거리 계산 (학교 기준)
                    let schoolLat = 35.1425
                    let schoolLng = 126.8005

                    let dist = self?.distance(
                        lat1: schoolLat,
                        lon1: schoolLng,
                        lat2: decoded.latitude,
                        lon2: decoded.longitude
                    ) ?? 0

                    let meters = dist * 111000
                    let minutes = Int(meters / 80)

                    self?.distanceText = "\(Int(meters))m"
                    self?.timeText = "\(minutes)분"

                    self?.fetchReviews(placeId: decoded.placeId)
                    self?.onDetailUpdated?()
                } else {
                    self?.onError?("상세 디코딩 실패")
                }
            case .failure:
                self?.onError?("상세 조회 실패")
            }
        }
    }

    public func fetchReviews(placeId: Int) {
        placeProvider.request(.getPlaceReviews(placeId: placeId, authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(MapReviewResponse.self, from: response.data)
                    self?.reviews = decoded.reviews
                    self?.onReviewsUpdated?()
                } catch {
                    self?.reviews = []
                    self?.onReviewsUpdated?()
                }
            case .failure:
                self?.onError?("리뷰 조회 실패")
            }
        }
    }
    
    public func fetchRecommendedCount(completion: (() -> Void)? = nil) {
        placeProvider.request(.getRecommendedPlacesCount(authorization: accessToken)) { [weak self] result in
            switch result {
            case .success:
                self?.fetchRecommendedPlaces()
                completion?()
            case .failure:
                self?.onError?("추천 개수 요청 실패")
                completion?()
            }
        }
    }

    public func toggleRecommend(placeId: Int, isSelected: Bool, completion: @escaping () -> Void) {
        let service: PlaceServices = isSelected
        ? .recommendPlace(placeId: placeId, authorization: accessToken)
        : .cancelRecommendPlace(placeId: placeId, authorization: accessToken)

        placeProvider.request(service) { [weak self] result in
            switch result {
            case .success:
                self?.fetchHotPlaces()
                self?.fetchRecommendedPlaces()
                completion()
            case .failure:
                self?.onError?("추천 상태 변경 실패")
                completion()
            }
        }
    }

    public func deleteReview(reviewId: Int, completion: @escaping (Bool) -> Void) {
        placeProvider.request(.deleteReview(reviewId: reviewId, authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                if response.statusCode == 204 {
                    completion(true)
                } else {
                    self?.onError?("리뷰 삭제 실패")
                    completion(false)
                }
            case .failure:
                self?.onError?("리뷰 삭제 요청 실패")
                completion(false)
            }
        }
    }

    public func fetchRoute(to place: MapPlaceData) {
        // 학교 좌표 (고정 출발지)
        let schoolLat = 35.1425
        let schoolLng = 126.8005

        placeProvider.request(.getRoute(
            startLat: schoolLat,
            startLng: schoolLng,
            endLat: place.latitude,
            endLng: place.longitude
        )) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MapRouteModel.self, from: response.data)
                    self?.routeResult = decoded

                    // 거리 / 시간 업데이트 (API 기준)
                    if let route = decoded.routes.first {
                        let summary = route.summary
                        self?.distanceText = "\(summary.distance)m"
                        self?.timeText = "\(summary.duration / 60)분"
                    }

                    self?.onRouteUpdated?()
                } catch {
                    self?.onError?("경로 디코딩 실패")
                }
            case .failure:
                self?.onError?("경로 요청 실패")
            }
        }
    }

    // MARK: - Logic

    public func findNearestPlace(lat: Double, lon: Double) -> MapPlaceData? {
        return allPlaces.min(by: {
            distance(lat1: lat, lon1: lon, lat2: $0.latitude, lon2: $0.longitude)
            <
            distance(lat1: lat, lon1: lon, lat2: $1.latitude, lon2: $1.longitude)
        })
    }

    public func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let dx = lat1 - lat2
        let dy = lon1 - lon2
        return sqrt(dx * dx + dy * dy)
    }

    public func calculateDistanceText(
        fromLat: Double,
        fromLon: Double,
        toLat: Double,
        toLon: Double
    ) -> (distance: String, time: String) {
        let dist = distance(lat1: fromLat, lon1: fromLon, lat2: toLat, lon2: toLon)
        let meters = dist * 111000
        let minutes = Int(meters / 80)
        return ("\(Int(meters))m", "\(minutes)분")
    }
    
    public func getRouteCoordinates() -> [(Double, Double)] {
        guard let route = routeResult?.routes.first else { return [] }
        
        var coords: [(Double, Double)] = []
        
        for section in route.sections {
            for road in section.roads {
                let v = road.vertexes
                for i in stride(from: 0, to: v.count, by: 2) {
                    let lng = v[i]
                    let lat = v[i + 1]
                    coords.append((lat, lng))
                }
            }
        }
        
        return coords
    }
}
