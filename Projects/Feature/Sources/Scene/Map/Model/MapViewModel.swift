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
import CoreLocation


public struct RecentSearchItem: Codable {
    let placeId: Int
    let searchedAt: Date
}

public final class MapViewModel {

    public enum StartLocationType {
        case school
        case currentLocation
    }

    // MARK: - Properties
    private let recentSearchKey = "recentSearches"
    private let placeProvider = MoyaProvider<PlaceServices>()
    
    public init() {
        loadRecentSearches()
    }
    
    private var accessToken: String {
        guard let token = KeyChain.shared.read(key: Const.KeyChainKey.accessToken) else {
            return ""
        }
        return "Bearer \(token)"
    }
    
    private func formatTime(minutes: Int) -> String {
        return "\(max(1, minutes))분"
    }

    // MARK: - Data
    public private(set) var allPlaces: [MapPlaceData] = []
    public private(set) var searchResults: [MapPlaceData] = []
    public private(set) var recentSearches: [RecentSearchItem] = []
    public private(set) var reviews: [MapReview] = []
    public private(set) var currentPlaceDetail: MapPlaceDetailModel?
    public private(set) var selectedPlaceId: Int = -1
    public private(set) var distanceText: String = ""
    public private(set) var timeText: String = ""
    public private(set) var hotPlaces: [MapPlaceData] = []
    public private(set) var recommendedPlaces: [MapPlaceData] = []
    public var lastSearchKeyword: String = ""

    // MARK: - Route Data
    public private(set) var routeResult: MapRouteModel?
    public var onRouteUpdated: (() -> Void)?
    public var currentLocation: (lat: Double, lng: Double)?
    
    // MARK: - School Gates
    private let mainGate = (lat: 35.143345842452526, lng:  126.80000822150454) // 정문
    private let backGate = (lat: 35.14266947162016, lng: 126.79979589504727) // 후문

    public private(set) var selectedGateName: String = "학교"

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
                    self?.loadRecentSearches()
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
        self.lastSearchKeyword = keyword
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

                    self?.distanceText = ""
                    self?.timeText = ""


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

    private func fetchRoute(startLat: Double, startLng: Double, endLat: Double, endLng: Double, shouldNotifyRouteUpdated: Bool = true) {
        placeProvider.request(.getRoute(
            startLat: startLat,
            startLng: startLng,
            endLat: endLat,
            endLng: endLng
        )) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MapRouteModel.self, from: response.data)
                    self?.routeResult = decoded

                    if let route = decoded.routes.first {
                        let summary = route.summary
                        self?.distanceText = "\(summary.distance)m"
                        let minutes = Int(ceil(Double(summary.duration) / 60.0))
                        self?.timeText = self?.formatTime(minutes: minutes) ?? "1분"
                        self?.onDetailUpdated?()
                    }

                    if shouldNotifyRouteUpdated {
                        self?.onRouteUpdated?()
                    }
                } catch {
                    self?.onError?("경로 디코딩 실패")
                }
            case .failure:
                self?.onError?("경로 요청 실패")
            }
        }
    }
    
    private func nearestGate(to place: MapPlaceData) -> (lat: Double, lng: Double, name: String) {
        let distMain = hypot(place.latitude - mainGate.lat, place.longitude - mainGate.lng)
        let distBack = hypot(place.latitude - backGate.lat, place.longitude - backGate.lng)

        return distMain < distBack
            ? (mainGate.lat, mainGate.lng, "학교 (정문)")
            : (backGate.lat, backGate.lng, "학교 (후문)")
    }

    public func fetchRoute(to place: MapPlaceData) {
        let gate = nearestGate(to: place)

        selectedGateName = gate.name

        fetchRoute(
            startLat: gate.lat,
            startLng: gate.lng,
            endLat: place.latitude,
            endLng: place.longitude,
            shouldNotifyRouteUpdated: true
        )
    }

    public func fetchRouteFromCurrentLocation(to place: MapPlaceData) {
        guard let current = currentLocation else {
            return
        }
        fetchRoute(
            startLat: current.lat,
            startLng: current.lng,
            endLat: place.latitude,
            endLng: place.longitude,
            shouldNotifyRouteUpdated: true
        )
    }

    public func fetchRouteFromPlace(
        start: MapPlaceData,
        endType: StartLocationType,
        currentLocation: CLLocation?
    ) {
        let endLat: Double
        let endLng: Double

        switch endType {
        case .school:
            let gate = nearestGate(to: start)
            selectedGateName = gate.name
            endLat = gate.lat
            endLng = gate.lng
        case .currentLocation:
            guard let currentLocation else { return }
            endLat = currentLocation.coordinate.latitude
            endLng = currentLocation.coordinate.longitude
        }

        fetchRoute(
            startLat: start.latitude,
            startLng: start.longitude,
            endLat: endLat,
            endLng: endLng,
            shouldNotifyRouteUpdated: true
        )
    }

    private func saveRecentSearches() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: recentSearchKey)
        }
    }

    private func loadRecentSearches() {
        guard let data = UserDefaults.standard.data(forKey: recentSearchKey) else {
            recentSearches = []
            return
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([RecentSearchItem].self, from: data) {
            recentSearches = decoded
        } else {
            recentSearches = []
        }
    }

    public func removeRecentSearch(placeId: Int) {
        recentSearches.removeAll { $0.placeId == placeId }
        saveRecentSearches()
    }

    public func addRecentSearch(placeId: Int) {
        let item = RecentSearchItem(placeId: placeId, searchedAt: Date())

    
        recentSearches.removeAll { $0.placeId == placeId }

        
        recentSearches.insert(item, at: 0)

        
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }

        saveRecentSearches()
    }

    public func getRecentSearchPlaces() -> [MapPlaceData] {
        return recentSearches.compactMap { item in
            allPlaces.first(where: { $0.placeId == item.placeId })
        }
    }

    // MARK: - Logic

    public func findNearestPlace(lat: Double, lon: Double) -> MapPlaceData? {
        return allPlaces.min(by: {
            let lhsDx = lat - $0.latitude
            let lhsDy = lon - $0.longitude
            let rhsDx = lat - $1.latitude
            let rhsDy = lon - $1.longitude
            let lhsDistance = sqrt(lhsDx * lhsDx + lhsDy * lhsDy)
            let rhsDistance = sqrt(rhsDx * rhsDx + rhsDy * rhsDy)
            return lhsDistance < rhsDistance
        })
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
