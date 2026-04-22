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
    public private(set) var myReviews: [MapReview] = []
    public var onMyReviewsUpdated: (() -> Void)?
    public private(set) var currentPlaceDetail: MapPlaceDetailModel?
    public private(set) var selectedPlaceId: Int = -1
    public private(set) var distanceText: String = ""
    public private(set) var timeText: String = ""
    public private(set) var hotPlaces: [MapPlaceData] = []
    public private(set) var recommendedPlaces: [MapPlaceData] = []
    public var lastSearchKeyword: String = ""

    // MARK: - Data
    // MARK: - Review Ownership (Server-based)
    public func isMyReview(_ review: MapReview) -> Bool {
        return review.isMine ?? false
    }

    // MARK: - Route Data
    public private(set) var routeResult: MapRouteModel?
    public var onRouteUpdated: (() -> Void)?
    public var currentLocation: (lat: Double, lng: Double)?

    // MARK: - Route Step (Direction)
    public struct RouteStep {
        let instruction: String
        let distance: Int
    }

    public private(set) var routeSteps: [RouteStep] = []
    
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

                    
                    if let placeData = self?.allPlaces.first(where: { $0.placeId == decoded.placeId }) {
                        self?.fetchRouteSilently(to: placeData)
                    }

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

    public func fetchMyReviews() {
        placeProvider.request(.getMyReviews(authorization: accessToken)) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(MyReviewResponse.self, from: response.data)

                    self?.myReviews = decoded.reviews.map {
                        MapReview(
                            reviewId: $0.reviewId,
                            placeId: $0.placeId,
                            memberId: 0,
                            name: $0.placeName,
                            grade: 0,
                            department: $0.categoryName,
                            profileImageUrl: "",
                            content: $0.content,
                            reviewedAt: $0.reviewedAt,
                            isMine: true
                        )
                    }
                    self?.onMyReviewsUpdated?()
                } catch {
                    self?.myReviews = []
                    self?.onMyReviewsUpdated?()
                }
            case .failure:
                self?.onError?("내 리뷰 조회 실패")
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
                if response.statusCode == 204 || response.statusCode == 200 {
                    self?.reviews.removeAll { $0.reviewId == reviewId }
                    self?.onReviewsUpdated?()
                    completion(true)
                } else {
                    self?.onError?("리뷰 삭제 실패 (status: \(response.statusCode))")
                    completion(false)
                }
            case .failure:
                self?.onError?("리뷰 삭제 요청 실패")
                completion(false)
            }
        }
    }

    public func reportReview(reviewId: Int, reason: String, completion: @escaping (Bool) -> Void) {
        let request = ReviewReportRequestDTO(content: reason)
        
        placeProvider.request(
            .reportReview(
                reviewId: reviewId,
                request: request,
                authorization: accessToken
            )
        ) { [weak self] result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 || response.statusCode == 201 {
                    completion(true)
                } else {
                    self?.onError?("리뷰 신고 실패")
                    completion(false)
                }
            case .failure:
                self?.onError?("리뷰 신고 요청 실패")
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
                    // step parsing
                    self?.routeSteps = self?.makeRouteSteps(from: decoded) ?? []

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

    
    public func fetchRouteSilently(to place: MapPlaceData) {
        let gate = nearestGate(to: place)

        selectedGateName = gate.name

        fetchRoute(
            startLat: gate.lat,
            startLng: gate.lng,
            endLat: place.latitude,
            endLng: place.longitude,
            shouldNotifyRouteUpdated: false
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

    public func fetchRouteFromCurrentLocationSilently(to place: MapPlaceData) {
        guard let current = currentLocation else { return }

        fetchRoute(
            startLat: current.lat,
            startLng: current.lng,
            endLat: place.latitude,
            endLng: place.longitude,
            shouldNotifyRouteUpdated: false
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
    // MARK: - Route Parsing (Direction)
    private func makeRouteSteps(from routeModel: MapRouteModel) -> [RouteStep] {
        guard let route = routeModel.routes.first else { return [] }

        var steps: [RouteStep] = []
        var previousPoint: CLLocationCoordinate2D?

        for section in route.sections {
            for road in section.roads {
                let vertexes = road.vertexes

                for i in stride(from: 0, to: vertexes.count - 2, by: 2) {
                    let current = CLLocationCoordinate2D(
                        latitude: vertexes[i + 1],
                        longitude: vertexes[i]
                    )

                    if let prev = previousPoint {
                        let next = CLLocationCoordinate2D(
                            latitude: vertexes[i + 3],
                            longitude: vertexes[i + 2]
                        )

                        let direction = getDirection(from: prev, via: current, to: next)
                        let distance = calculateDistance(from: current, to: next)

                        steps.append(
                            RouteStep(
                                instruction: direction,
                                distance: distance
                            )
                        )
                    }

                    previousPoint = current
                }
            }
        }

        return steps
    }

    private func getDirection(
        from prev: CLLocationCoordinate2D,
        via current: CLLocationCoordinate2D,
        to next: CLLocationCoordinate2D
    ) -> String {

        let angle = calculateAngle(prev: prev, current: current, next: next)

        if angle > 30 {
            return "우회전"
        } else if angle < -30 {
            return "좌회전"
        } else {
            return "직진"
        }
    }

    private func calculateAngle(
        prev: CLLocationCoordinate2D,
        current: CLLocationCoordinate2D,
        next: CLLocationCoordinate2D
    ) -> Double {

        let v1 = (
            x: current.longitude - prev.longitude,
            y: current.latitude - prev.latitude
        )

        let v2 = (
            x: next.longitude - current.longitude,
            y: next.latitude - current.latitude
        )

        let dot = v1.x * v2.x + v1.y * v2.y
        let det = v1.x * v2.y - v1.y * v2.x

        return atan2(det, dot) * 180 / .pi
    }

    private func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Int {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1) * cos(lat2) *
                sin(dLon/2) * sin(dLon/2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = 6371000 * c

        return Int(distance)
    }
}
