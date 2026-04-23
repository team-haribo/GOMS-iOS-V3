
//  MapViewController.swift
//  Feature
//
//  Created by 김민선 on 2/13/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit
import SnapKit
import Then
import KakaoMapsSDK
import Service
import CoreLocation

public final class MapViewController: UIViewController, MapControllerDelegate, KakaoMapEventDelegate, CLLocationManagerDelegate {
    private let schoolFrontLat: Double = 35.14342015456559
    private let schoolFrontLng: Double = 126.79997786265704

    private var currentLocationPoi: Poi?
    private var pulsePoi: Poi?
private func resetUIForNewSelection() {
    routeSelectionView.isHidden = true
    recentSearchView.isHidden = true
    bottomSheetView.isHidden = true
    placeDetailView.isHidden = false
    searchBar.isHidden = false
}
private let viewModel = MapViewModel()
private let locationManager = CLLocationManager()
private var currentLocation: CLLocation?
private var pendingRoutePlace: MapPlaceData?

typealias StartLocationType = MapViewModel.StartLocationType

private var startLocationType: StartLocationType = .school
private var endLocationType: StartLocationType = .school
private var isStartFixedToPin: Bool = false

    private func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371000.0
        
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
        
private let distanceThreshold: Double = 50.0
private var mapContainer: KMViewContainer?
private var mapController: KMController?
private let mapWrapperView = UIView()

private var allPlaces: [MapPlaceData] = []
private var dummyRecentSearches: [MapPlaceData] = [] {
    didSet { self.recentSearchView.tableView.reloadData() }
}
private var isShowingRecentSearches = true


private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
private let searchBar = MapSearchBar()
private let recentSearchView = MapRecentSearchView().then {
    $0.isHidden = true
    $0.backgroundColor = .color.background.color
    $0.tableView.backgroundColor = .color.background.color
}
private let bottomSheetView = MapBottomSheetView()
private let bottomSheetHandleTouchArea = UIView().then {
    $0.backgroundColor = .clear
}
private let placeDetailView = MapPlaceDetailView().then {
    $0.isHidden = true
    $0.clipsToBounds = true
}

private var bottomSheetHeight: Constraint?
private var detailSheetHeight: Constraint?
private let defaultHeight: CGFloat = 240
private let firstHeight: CGFloat = 30
private let detailMinHeight: CGFloat = 225
private var selectedPlaceId: Int = -1
private var currentPlaceDetail: MapPlaceDetailModel?
private var routeDetailVC: MapRouteDetailViewController?

private var isRestoringState = false
private var isSearching = false


private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd"
    return formatter.string(from: date)
}

public override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.edgesForExtendedLayout = [.top]
    setupView()
    setupLayout()
    setupDelegate()
    setupGesture()
    setupActions()
    setupReviewWriteAction()
    setupLocationManager()
    if let location = locationManager.location {
        showCurrentLocationMarker(location)
    }

    setupMap()
    bindViewModel()
    setupBottomSheetBinding()
    fetchPlaceList()
    viewModel.fetchHotPlaces()
    viewModel.fetchRecommendedPlaces()
    viewModel.fetchMyReviews()
}
private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.activityType = .fitness
    locationManager.allowsBackgroundLocationUpdates = false
    locationManager.showsBackgroundLocationIndicator = false
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.requestLocation()
}

public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
}

public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isRestoringState = true
    view.endEditing(true)

    if selectedPlaceId != -1 {
        fetchReviews(placeId: selectedPlaceId)
        viewModel.fetchPlaceDetail(placeId: selectedPlaceId)
        viewModel.fetchHotPlaces()
        viewModel.fetchRecommendedPlaces()
    }

    if viewModel.lastSearchKeyword.isEmpty {
        searchBar.updateState(.home)
        searchBar.textField.text = ""
    } else {
        searchBar.updateState(.search)
        searchBar.textField.text = viewModel.lastSearchKeyword
    }

    if isSearching {
        recentSearchView.isHidden = false
        bottomSheetView.isHidden = true
        placeDetailView.isHidden = true

        if viewModel.lastSearchKeyword.isEmpty {
            isShowingRecentSearches = true
            dummyRecentSearches = viewModel.recentSearches.compactMap { item in
                self.allPlaces.first(where: { $0.placeId == item.placeId })
            }
            recentSearchView.titleLabel.text = "최근 검색"
        } else if viewModel.searchResults.isEmpty {
            isShowingRecentSearches = true
            dummyRecentSearches = viewModel.recentSearches.compactMap { item in
                self.allPlaces.first(where: { $0.placeId == item.placeId })
            }
            recentSearchView.titleLabel.text = "검색 결과가 없습니다"
        } else {
            isShowingRecentSearches = false
            dummyRecentSearches = viewModel.searchResults
            recentSearchView.titleLabel.text = "'\(viewModel.lastSearchKeyword)' 검색 결과"
        }
    } else {
        recentSearchView.isHidden = true
        bottomSheetView.isHidden = false
        placeDetailView.isHidden = true
    }


    if selectedPlaceId != -1 {
       
        self.placeDetailView.isHidden = false
        self.bottomSheetView.isHidden = true

        self.bottomSheetHeight?.update(offset: 0)
        self.detailSheetHeight?.update(offset: self.detailMinHeight)
    } else {
      
        self.placeDetailView.isHidden = true
        self.bottomSheetView.isHidden = false

        self.bottomSheetHeight?.update(offset: self.defaultHeight)
        self.detailSheetHeight?.update(offset: 0)
    }

    self.view.layoutIfNeeded()

    DispatchQueue.main.async {
        self.isRestoringState = false
    }
}

public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
}

public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
}

private func setupView() {
    self.view.backgroundColor = .black
    view.backgroundColor = .color.background.color
    view.addSubview(mapWrapperView)
    [bottomSheetView, bottomSheetHandleTouchArea, recentSearchView, routeSelectionView, placeDetailView, searchBar].forEach { view.addSubview($0) }
}

private func setupLayout() {
    mapWrapperView.snp.makeConstraints { $0.edges.equalToSuperview() }
    routeSelectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    searchBar.snp.makeConstraints {
        $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        $0.leading.trailing.equalToSuperview().inset(24)
        $0.height.equalTo(52)
    }
    bottomSheetView.snp.makeConstraints {
        $0.leading.trailing.bottom.equalToSuperview()
        self.bottomSheetHeight = $0.height.equalTo(defaultHeight).constraint
    }
    bottomSheetHandleTouchArea.snp.makeConstraints {
        $0.leading.trailing.equalToSuperview()
        $0.bottom.equalTo(bottomSheetView.snp.top)
        $0.height.equalTo(30)
    }
    placeDetailView.snp.makeConstraints {
        $0.leading.trailing.bottom.equalToSuperview()
        self.detailSheetHeight = $0.height.equalTo(0).priority(.high).constraint
    }
    recentSearchView.snp.makeConstraints { $0.edges.equalToSuperview() }
    recentSearchView.titleStack.snp.remakeConstraints {
        $0.top.equalTo(searchBar.snp.bottom).offset(20)
        $0.leading.equalToSuperview().inset(24)
    }
    recentSearchView.tableView.snp.remakeConstraints {
        $0.top.equalTo(recentSearchView.titleStack.snp.bottom).offset(12)
        $0.leading.trailing.equalToSuperview()
        $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
}

private func setupDelegate() {
    [recentSearchView.tableView, placeDetailView.tableView].forEach {
        $0.delegate = self
        $0.dataSource = self
    }
}

private func setupActions() {
    placeDetailView.closeButton.addTarget(self, action: #selector(didTapCloseDetailButton), for: .touchUpInside)
    placeDetailView.arriveButton.addTarget(self, action: #selector(didTapArriveRoute), for: .touchUpInside)
    placeDetailView.startRouteButton.addTarget(self, action: #selector(didTapStartRoute), for: .touchUpInside)
    routeSelectionView.backButton.addTarget(self, action: #selector(backFromRouteSelection), for: .touchUpInside)
    bottomSheetView.onCardTapped = { [weak self] placeId in
        guard let self = self else { return }
        if let selected = self.allPlaces.first(where: { $0.placeId == placeId }) {
            self.selectedPlaceId = selected.placeId
            self.resetUIForNewSelection()

            
            self.moveCamera(to: selected)
            self.showActiveMarker(for: selected)

          
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.showDetailView(with: selected)
            }

            
            self.bottomSheetView.isHidden = true
            self.recentSearchView.isHidden = true
            self.searchBar.isHidden = false

            self.viewModel.fetchHotPlaces()
            self.viewModel.fetchRecommendedPlaces()
        }
    }
    bottomSheetView.onHeartTapped = { [weak self] placeId, isSelected in
        guard let self = self else { return }

    
        self.updateBottomSheet()

       
        self.viewModel.toggleRecommend(placeId: placeId, isSelected: isSelected) {
            
            self.viewModel.fetchHotPlaces()
            self.viewModel.fetchRecommendedPlaces()
            self.viewModel.fetchMyReviews()
        }
    }

    bottomSheetView.onDeleteTapped = { [weak self] placeId in
        guard let self = self else { return }

        
        guard let review = self.viewModel.myReviews.first(where: { $0.placeId == placeId }) else {
            return
        }

        ReviewAlert.show(in: self, title: "후기 삭제", message: "작성하신 후기를 정말 삭제하시겠습니까?") { _ in
            self.placeDetailView.isUserInteractionEnabled = false

            self.viewModel.deleteReview(reviewId: review.reviewId) { [weak self] success in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.placeDetailView.isUserInteractionEnabled = true
                }

                guard success else {
                    DispatchQueue.main.async {
                        ReviewAlert.showSingle(
                            in: self,
                            title: "알림",
                            message: "후기 삭제에 실패했습니다.",
                            buttonTitle: "확인"
                        )
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.viewModel.fetchMyReviews()
                    self.viewModel.fetchHotPlaces()
                    self.viewModel.fetchRecommendedPlaces()
                    self.updateBottomSheet()
                }
            }
        }
    }
    searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
    searchBar.textField.addTarget(self, action: #selector(performSearch), for: .editingDidEndOnExit)
    searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
    placeDetailView.onHeartToggled = { [weak self] isSelected in
        guard let self = self, self.selectedPlaceId != -1 else { return }

        let previousRecommended = self.currentPlaceDetail?.recommended ?? false
        let previousRecommendCount = self.currentPlaceDetail?.recommendCount ?? 0

        self.viewModel.toggleRecommend(placeId: self.selectedPlaceId, isSelected: isSelected) {
            DispatchQueue.main.async {
                if var detail = self.currentPlaceDetail {
                    detail.recommended = isSelected

                    if previousRecommended != isSelected {
                        detail.recommendCount = max(
                            0,
                            previousRecommendCount + (isSelected ? 1 : -1)
                        )
                    }

                    self.currentPlaceDetail = detail

                    self.placeDetailView.configure(
                        with: detail,
                        distanceText: self.viewModel.distanceText,
                        timeText: self.viewModel.timeText,
                        reviews: self.placeDetailView.currentReviews
                    )
                }

              
                self.updateBottomSheet()
            }

       
            self.viewModel.fetchHotPlaces()
            self.viewModel.fetchRecommendedPlaces()
            self.viewModel.fetchMyReviews()
        }
    }
    routeSelectionView.onCardTapped = { [weak self] routeTitle in
        guard let self = self else { return }
        guard self.viewModel.routeResult != nil else { return }

        let detailVC = MapRouteDetailViewController()
        detailVC.routeTypeTitle = routeTitle
        detailVC.destinationName = self.allPlaces.first(where: { $0.placeId == self.selectedPlaceId })?.placeName ?? ""
        detailVC.modalPresentationStyle = .overFullScreen
        detailVC.onDismiss = { [weak self] in
            self?.routeSelectionView.isHidden = true
            self?.placeDetailView.isHidden = false
            self?.searchBar.isHidden = false
            self?.detailSheetHeight?.update(offset: self?.detailMinHeight ?? 225)
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
        }

        self.routeDetailVC = detailVC
        self.routeSelectionView.isHidden = true
        self.searchBar.isHidden = true

        self.addChild(detailVC)
        self.view.addSubview(detailVC.view)
        detailVC.view.frame = self.view.bounds
        detailVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        detailVC.view.backgroundColor = .clear
        self.view.bringSubviewToFront(detailVC.view)
        detailVC.didMove(toParent: self)

        self.routeDetailVC?.routeResult = self.viewModel.routeResult
        self.routeDetailVC?.perform(#selector(MapRouteDetailViewController.viewDidLoad))
    }
    routeSelectionView.onStartLocationChanged = { [weak self] type in
        guard let self = self else { return }
        

        self.startLocationType = (type == .currentLocation) ? .currentLocation : .school

        if type == .currentLocation {
            self.routeSelectionView.setStartLocation(.currentLocation)
        } else {
            self.routeSelectionView.setStartLocation(.school)
        }

        guard let selectedPlace = self.allPlaces.first(where: { $0.placeId == self.selectedPlaceId }) else {
            return
        }

        if self.isStartFixedToPin {
            return
        }

        if type == .currentLocation {
           
            if let current = self.currentLocation {
                self.viewModel.currentLocation = (
                    lat: current.coordinate.latitude,
                    lng: current.coordinate.longitude
                )
                self.requestRoute(to: selectedPlace)
            } else {
               
                self.pendingRoutePlace = selectedPlace
                self.locationManager.requestLocation()
            }
        } else {
            self.requestRoute(to: selectedPlace)
        }
    }

    routeSelectionView.onEndLocationChanged = { [weak self] type in
        guard let self = self else { return }

        self.endLocationType = (type == .currentLocation) ? .currentLocation : .school

        if type == .currentLocation {
            self.routeSelectionView.setEndLocation(.currentLocation)
        } else {
            self.routeSelectionView.setEndLocation(.school)
        }

        guard let selectedPlace = self.allPlaces.first(where: { $0.placeId == self.selectedPlaceId }) else {
            return
        }

        if !self.isStartFixedToPin {
            return
        }

        if self.endLocationType == .currentLocation, self.currentLocation == nil {
            self.pendingRoutePlace = selectedPlace
            self.locationManager.requestLocation()
            return
        }

        self.requestRoute(to: selectedPlace)
    }

    routeSelectionView.onReverseTapped = { [weak self] in
        guard let self = self else { return }

       
        let tempStart = self.startLocationType
        self.startLocationType = self.endLocationType
        self.endLocationType = tempStart

        
        let tempFixed = self.isStartFixedToPin
        self.isStartFixedToPin = !tempFixed

        
        let startUI: RouteStartLocationType =
            (self.startLocationType == .currentLocation) ? .currentLocation : .school
        let endUI: RouteStartLocationType =
            (self.endLocationType == .currentLocation) ? .currentLocation : .school

        self.routeSelectionView.setStartLocation(startUI)
        self.routeSelectionView.setEndLocation(endUI)

        self.routeSelectionView.setStartFixed(self.isStartFixedToPin)
        self.routeSelectionView.setEndFixed(!self.isStartFixedToPin)

        
        self.routeSelectionView.swapLocations()

      
        guard let selectedPlace = self.allPlaces.first(where: { $0.placeId == self.selectedPlaceId }) else {
            return
        }

        if self.isStartFixedToPin {
        
            self.routeSelectionView.setStartPlaceName(selectedPlace.placeName)

            if self.endLocationType == .school {
                self.routeSelectionView.setEndLocation(.school)
            } else {
                self.routeSelectionView.setEndLocation(.currentLocation)
            }

        } else {
        
            self.routeSelectionView.setEndPlaceName(selectedPlace.placeName)

            if self.startLocationType == .school {
                self.routeSelectionView.setStartLocation(.school)
            } else {
                self.routeSelectionView.setStartLocation(.currentLocation)
            }
        }

       
        if self.startLocationType == .currentLocation && self.currentLocation == nil {
            self.pendingRoutePlace = selectedPlace
            self.locationManager.requestLocation()
            return
        }

        if self.isStartFixedToPin &&
           self.endLocationType == .currentLocation &&
           self.currentLocation == nil {
            self.pendingRoutePlace = selectedPlace
            self.locationManager.requestLocation()
            return
        }

       
        self.requestRoute(to: selectedPlace)
    }

}

private func setupReviewWriteAction() { placeDetailView.reviewWriteButton.addTarget(self, action: #selector(didTapReviewWrite), for: .touchUpInside) }

private func fetchPlaceList() {
    viewModel.fetchAllPlaces()
}


private func fetchReviews(placeId: Int) {
    viewModel.fetchReviews(placeId: placeId)
}

@objc private func performSearch() {
    guard let keyword = searchBar.textField.text, !keyword.isEmpty else { return }

    viewModel.searchPlace(keyword: keyword)

   
    recentSearchView.isHidden = false
    bottomSheetView.isHidden = true
    placeDetailView.isHidden = true

    
    view.endEditing(true)
}

@objc private func didTapReviewWrite() {
    guard let detailData = currentPlaceDetail else { return }

    let vc = MapReviewWriteViewController(placeData: detailData)

    vc.onReviewCreated = { [weak self] in
        guard let self = self else { return }

        self.fetchReviews(placeId: detailData.placeId)
        self.viewModel.fetchPlaceDetail(placeId: detailData.placeId)
        self.viewModel.fetchHotPlaces()
        self.viewModel.fetchRecommendedPlaces()
       
        self.selectedPlaceId = detailData.placeId

        self.bottomSheetView.isHidden = true
        self.placeDetailView.isHidden = false

        self.bottomSheetHeight?.update(offset: 0)
        self.detailSheetHeight?.update(offset: self.detailMinHeight)

        self.view.layoutIfNeeded()
    }

    self.navigationController?.pushViewController(vc, animated: true)
}

private func showCurrentLocationMarker(_ location: CLLocation) {
    guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
    let manager = map.getLabelManager()

    if manager.getLabelLayer(layerID: "currentLocationLayer") == nil {
        _ = manager.addLabelLayer(
            option: LabelLayerOptions(
                layerID: "currentLocationLayer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 30000
            )
        )
    }
    
    if manager.getLabelLayer(layerID: "pulseLayer") == nil {
        _ = manager.addLabelLayer(
            option: LabelLayerOptions(
                layerID: "pulseLayer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 29999
            )
        )
    }

    guard let layer = manager.getLabelLayer(layerID: "currentLocationLayer") else { return }
    guard let pulseLayer = manager.getLabelLayer(layerID: "pulseLayer") else { return }

    if let poi = currentLocationPoi {
        poi.moveAt(
            MapPoint(
                longitude: location.coordinate.longitude,
                latitude: location.coordinate.latitude
            ),
            duration: 100
        )
        
        if let pulsePoi = pulsePoi {
            pulsePoi.moveAt(
                MapPoint(
                    longitude: location.coordinate.longitude,
                    latitude: location.coordinate.latitude
                ),
                duration: 100
            )
        }
        return
    }

    let option = PoiOptions(styleID: "activePinStyle", poiID: "currentLocation")
    option.clickable = false

    if let poi = layer.addPoi(
        option: option,
        at: MapPoint(
            longitude: location.coordinate.longitude,
            latitude: location.coordinate.latitude
        )
    ) {
        poi.show()
        currentLocationPoi = poi
        
        let pulseOption = PoiOptions(styleID: "pulseStyle", poiID: "pulse")
        pulseOption.clickable = false

        if let pPoi = pulseLayer.addPoi(
            option: pulseOption,
            at: MapPoint(
                longitude: location.coordinate.longitude,
                latitude: location.coordinate.latitude
            )
        ) {
            pPoi.show()
            pulsePoi = pPoi
        }
    }
}




private func renderAllPlaceMarkers() {
    guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
    let manager = view.getLabelManager()
    guard let layer = manager.getLabelLayer(layerID: "poiLayer") else { return }

    let existingPoiIDs = layer.getAllPois()?.map { $0.itemID } ?? []
    layer.removePois(poiIDs: existingPoiIDs)

    for place in allPlaces {
        let styleID = styleIDForCategory(place.categoryName)
        guard !styleID.isEmpty else { continue }
        let option = PoiOptions(styleID: styleID, poiID: "\(place.placeId)")
        option.clickable = true
        option.rank = 0
        if let poi = layer.addPoi(option: option, at: MapPoint(longitude: place.longitude, latitude: place.latitude)) {
            poi.show()
        }
    }
}

private func styleIDForCategory(_ category: String) -> String {
    if category.contains("편의점") {
        return "CS2"
    } else if category.contains("슈퍼") {
        return "MT1"
    } else if category.contains("문화") || category.contains("공연") || category.contains("미술관") {
        return "CT1"
    } else if category.contains("음식점") || category.contains("치킨") || category.contains("피자") || category.contains("한식") || category.contains("중식") || category.contains("일식") {
        return "FD6"
    } else if category.contains("카페") || category.contains("베이커리") {
        return "CE7"
    } else if category.contains("병원") {
        return "HP8"
    } else if category.contains("약국") {
        return "PM9"
    } else if category.contains("관광") || category.contains("명소") {
        return "AT4"
    }
    return ""
}

@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    let isDetail = gesture.view == placeDetailView
    let translation = gesture.translation(in: view)
    let currentHeight = isDetail ? placeDetailView.frame.height : bottomSheetView.frame.height
    let newHeight = currentHeight - translation.y
    let minH = isDetail ? detailMinHeight : firstHeight
    let secondH = defaultHeight
    let maxH = view.frame.height - (searchBar.frame.maxY + 20)
    if gesture.state == .changed {
        let clampedHeight = max(minH, min(newHeight, maxH))
        if isDetail { detailSheetHeight?.update(offset: clampedHeight) }
        else { bottomSheetHeight?.update(offset: clampedHeight) }
    } else if gesture.state == .ended {
        let targetHeight: CGFloat

        if newHeight < (minH + secondH) / 2 {
            targetHeight = minH
        } else if newHeight < (secondH + maxH) / 2 {
            targetHeight = secondH
        } else {
            targetHeight = maxH
        }

        UIView.animate(withDuration: 0.3) {
            if isDetail {
                self.detailSheetHeight?.update(offset: targetHeight)
            } else {
                self.bottomSheetHeight?.update(offset: targetHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    gesture.setTranslation(.zero, in: view)
}

private func setupGesture() {
    bottomSheetHandleTouchArea.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    bottomSheetView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    placeDetailView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
}

private func showDetailView(with data: MapPlaceData? = nil) {
    let isFirstShow = placeDetailView.isHidden

    if isFirstShow {
        self.detailSheetHeight?.update(offset: 0)
        self.view.layoutIfNeeded()
    }

    if isFirstShow {
        self.bottomSheetHeight?.update(offset: 0)
        self.view.layoutIfNeeded()
        self.bottomSheetView.isHidden = true
    }

    if let data = data {
        self.selectedPlaceId = data.placeId

        self.currentPlaceDetail = nil

        placeDetailView.configure(
            with: MapPlaceDetailModel(
                placeId: data.placeId,
                placeName: data.placeName,
                address: data.address,
                roadAddress: data.address,
                latitude: data.latitude,
                longitude: data.longitude,
                categoryGroupName: "",
                categoryName: data.categoryName,
                phone: "",
                placeUrl: "",
                reviewCount: 0,
                recommendCount: 0,
                recommended: false
            ),
            distanceText: "",
            timeText: "",
            reviews: self.viewModel.reviews
        )

        viewModel.fetchPlaceDetail(placeId: data.placeId)
        fetchReviews(placeId: data.placeId)
        viewModel.fetchRouteSilently(to: data)
    } else {
        let detailModel = MapMockData.detailExample
        self.selectedPlaceId = detailModel.placeId
        self.currentPlaceDetail = detailModel
        fetchReviews(placeId: self.selectedPlaceId)

        placeDetailView.configure(
            with: detailModel,
            distanceText: "",
            timeText: "",
            reviews: self.viewModel.reviews
        )
    }

    placeDetailView.isHidden = false
    searchBar.isHidden = false
   
    if isFirstShow {
       
        self.detailSheetHeight?.update(offset: 0)
        self.view.layoutIfNeeded()

        self.placeDetailView.isHidden = false

        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations: {
            self.detailSheetHeight?.update(offset: self.detailMinHeight)
            self.view.layoutIfNeeded()
        })
    } else {
        UIView.transition(
            with: self.placeDetailView,
            duration: 0.25,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: {
                self.placeDetailView.layoutIfNeeded()
            }
        )
    }
}
private func bindViewModel() {
    viewModel.onPlacesUpdated = { [weak self] in
        self?.allPlaces = self?.viewModel.allPlaces ?? []
        self?.renderAllPlaceMarkers()
        self?.updateBottomSheet()
    }

    viewModel.onSearchUpdated = { [weak self] in
        guard let self = self else { return }
        let keyword = self.searchBar.textField.text ?? ""

        if keyword.isEmpty || self.viewModel.searchResults.isEmpty {
            self.isShowingRecentSearches = true
            self.dummyRecentSearches = self.viewModel.recentSearches.compactMap { item in
                self.allPlaces.first(where: { $0.placeId == item.placeId })
            }
            self.recentSearchView.titleLabel.text = keyword.isEmpty
                ? "최근 검색"
                : "검색 결과가 없습니다"
        } else {
            self.isShowingRecentSearches = false
            self.dummyRecentSearches = self.viewModel.searchResults
            self.recentSearchView.titleLabel.text = "'\(keyword)' 검색 결과"
        }

        self.recentSearchView.isHidden = false
        self.bottomSheetView.isHidden = true
    }

    viewModel.onReviewsUpdated = { [weak self] in
        guard let self = self else { return }
       


        DispatchQueue.main.async {
            self.placeDetailView.isUserInteractionEnabled = true
            self.placeDetailView.updateReviewCount(
                self.viewModel.reviews.count,
                recommendCount: self.currentPlaceDetail?.recommendCount ?? 0
            )

            self.placeDetailView.configure(
                with: self.currentPlaceDetail ?? MapPlaceDetailModel(
                    placeId: self.selectedPlaceId,
                    placeName: "",
                    address: "",
                    roadAddress: "",
                    latitude: 0,
                    longitude: 0,
                    categoryGroupName: "",
                    categoryName: "",
                    phone: "",
                    placeUrl: "",
                    reviewCount: self.viewModel.reviews.count,
                    recommendCount: self.currentPlaceDetail?.recommendCount ?? 0,
                    recommended: self.currentPlaceDetail?.recommended ?? false
                ),
                distanceText: self.viewModel.distanceText,
                timeText: self.viewModel.timeText,
                reviews: self.viewModel.reviews
            )
            self.updateBottomSheet()
            self.placeDetailView.setNeedsLayout()
            self.placeDetailView.layoutIfNeeded()
        }
    }

    viewModel.onDetailUpdated = { [weak self] in
        guard let self = self,
              let detail = self.viewModel.currentPlaceDetail else { return }

        guard detail.placeId == self.selectedPlaceId else { return }

        self.selectedPlaceId = detail.placeId
        self.currentPlaceDetail = detail

        self.placeDetailView.configure(
            with: detail,
            distanceText: self.viewModel.distanceText,
            timeText: self.viewModel.timeText,
            reviews: self.placeDetailView.currentReviews
        )

        self.updateViewVisibility()
    }
    viewModel.onHotPlacesUpdated = { [weak self] in
        self?.updateBottomSheet()
    }
    viewModel.onRecommendedPlacesUpdated = { [weak self] in
        self?.updateBottomSheet()
    }
    viewModel.onRouteUpdated = { [weak self] in
        guard let self = self else { return }
        DispatchQueue.main.async {
            let routes = self.viewModel.routeResult?.routes ?? []

            let cardData: [RouteCardData] = routes.enumerated().map { index, route in
                let summary = route.summary
                let minutes = max(1, Int(ceil(Double(summary.duration) / 60.0)))

                return RouteCardData(
                    title: index == 0 ? "추천" : "경로 \(index + 1)",
                    time: "\(minutes)분",
                    info: "\(summary.distance)m"
                )
            }

            
            self.placeDetailView.isHidden = true
            self.bottomSheetView.isHidden = true
            self.recentSearchView.isHidden = true
            self.searchBar.isHidden = true

            self.routeSelectionView.configure(routes: cardData)
            self.routeSelectionView.isHidden = false
            self.view.bringSubviewToFront(self.routeSelectionView)

            self.drawRoute()
        }
    }
    viewModel.onMyReviewsUpdated = { [weak self] in
        self?.updateBottomSheet()
    }
}

private func setupBottomSheetBinding() {
   
    updateBottomSheet()
}

private func updateBottomSheet() {
    let popular: [MapCardData] = viewModel.hotPlaces.prefix(5).map { place in
        MapCardData(
            id: place.placeId,
            name: place.placeName,
            address: place.address,
            category: place.categoryName,
            reviewCount: place.reviewCount,
            recommendCount: place.recommendCount,
            isFavorite: place.recommended
        )
    }

    if selectedPlaceId == -1 {
        let recommended: [MapCardData] = viewModel.recommendedPlaces.map { place in
            MapCardData(
                id: place.placeId,
                name: place.placeName,
                address: place.address,
                category: place.categoryName,
                reviewCount: place.reviewCount,
                recommendCount: place.recommendCount,
                isFavorite: place.recommended
            )
        }

        let reviews: [MapCardData] = viewModel.myReviews.compactMap { review in
            guard let place = self.allPlaces.first(where: { $0.placeId == review.placeId }) else { return nil }
            return MapCardData(
                id: place.placeId,
                name: place.placeName,
                address: place.address,
                category: place.categoryName,
                reviewCount: place.reviewCount,
                recommendCount: place.recommendCount,
                isFavorite: place.recommended
            )
        }

        bottomSheetView.configure(
            popular: Array(popular),
            recommended: recommended,
            reviews: reviews
        )
        return
    }

    let recommended: [MapCardData] = viewModel.recommendedPlaces
        .filter { $0.placeId == selectedPlaceId }
        .map { place in
            MapCardData(
                id: place.placeId,
                name: place.placeName,
                address: place.address,
                category: place.categoryName,
                reviewCount: place.reviewCount,
                recommendCount: place.recommendCount,
                isFavorite: place.recommended
            )
        }

    let reviews: [MapCardData] = viewModel.myReviews.compactMap { review in
        guard let place = self.allPlaces.first(where: { $0.placeId == review.placeId }) else { return nil }
        return MapCardData(
            id: place.placeId,
            name: place.placeName,
            address: place.address,
            category: place.categoryName,
            reviewCount: place.reviewCount,
            recommendCount: place.recommendCount,
            isFavorite: place.recommended
        )
    }

    bottomSheetView.configure(
        popular: Array(popular),
        recommended: recommended,
        reviews: reviews
    )
}

private func updateViewVisibility() {
    placeDetailView.isHidden = false
    searchBar.isHidden = false
    detailSheetHeight?.update(offset: detailMinHeight)

    UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
    }
}


@objc private func didTapCloseDetailButton() {
   
    if let map = mapController?.getView("mapview") as? KakaoMap {
        let manager = map.getShapeManager()
        if let layer = manager.getShapeLayer(layerID: "routeLayer") {
            layer.removeMapPolylineShape(shapeID: "routeShape")
            layer.removeMapPolylineShape(shapeID: "routeGlowShape")
        }
    }

    hideDetailView()
}

private func hideDetailView(completion: (() -> Void)? = nil) {
    if let view = mapController?.getView("mapview") as? KakaoMap,
       let activeLayer = view.getLabelManager().getLabelLayer(layerID: "activePoiLayer") {
        activeLayer.removePois(poiIDs: activeLayer.getAllPois()?.map { $0.itemID } ?? [])
    }

    UIView.animate(withDuration: 0.3, animations: { [weak self] in
        guard let self = self else { return }
        self.detailSheetHeight?.update(offset: 0)
        self.view.layoutIfNeeded()
    }) { [weak self] _ in
        guard let self = self else { return }
        self.placeDetailView.isHidden = true
        self.bottomSheetView.isHidden = false

        self.bottomSheetHeight?.update(offset: self.defaultHeight)
        self.view.layoutIfNeeded()

        self.selectedPlaceId = -1
        self.currentPlaceDetail = nil

        let completionHandler = completion
        completionHandler?()
    }
}

@objc private func backToHome() {
    isSearching = false
    isShowingRecentSearches = true
    hideDetailView()
    recentSearchView.isHidden = true
    bottomSheetView.isHidden = false
    searchBar.updateState(.home)
    searchBar.isHidden = false
    searchBar.textField.text = ""
    viewModel.lastSearchKeyword = ""
    view.endEditing(true)
}

@objc private func didTapSearchBar() {
    if isRestoringState { return }
    isSearching = true

    if !placeDetailView.isHidden {
        hideDetailView()
    }

    searchBar.updateState(.search)
    recentSearchView.isHidden = false

    let keyword = viewModel.lastSearchKeyword

    if keyword.isEmpty {
        isShowingRecentSearches = true
        dummyRecentSearches = viewModel.recentSearches.compactMap { item in
            self.allPlaces.first(where: { $0.placeId == item.placeId })
        }
        recentSearchView.titleLabel.text = "최근 검색"
    } else {
        if viewModel.searchResults.isEmpty {
            isShowingRecentSearches = true
            dummyRecentSearches = viewModel.recentSearches.compactMap { item in
                self.allPlaces.first(where: { $0.placeId == item.placeId })
            }
            recentSearchView.titleLabel.text = "검색 결과가 없습니다"
        } else {
            isShowingRecentSearches = false
            dummyRecentSearches = viewModel.searchResults
            recentSearchView.titleLabel.text = "'\(keyword)' 검색 결과"
        }
    }
}
@objc private func didTapArriveRoute() {
    guard let selectedPlace = allPlaces.first(where: { $0.placeId == selectedPlaceId }) else {
        return
    }
    isStartFixedToPin = false

    
    let mappedType: RouteStartLocationType = (self.startLocationType == .currentLocation) ? .currentLocation : .school
    self.endLocationType = .school
    routeSelectionView.setStartLocation(mappedType)
    routeSelectionView.setStartFixed(false)
    routeSelectionView.setEndFixed(true)

    
    routeSelectionView.setEndPlaceName(selectedPlace.placeName)

    routeSelectionView.isHidden = false
    view.bringSubviewToFront(routeSelectionView)
    searchBar.isHidden = true
    [bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true }

    requestRoute(to: selectedPlace)
}

@objc private func didTapStartRoute() {
    guard let selectedPlace = allPlaces.first(where: { $0.placeId == selectedPlaceId }) else {
        return
    }


    routeSelectionView.setStartPlaceName(selectedPlace.placeName)
    routeSelectionView.setStartFixed(true)
    isStartFixedToPin = true

   
    self.endLocationType = self.startLocationType
    let endType: RouteStartLocationType = (self.endLocationType == .currentLocation) ? .currentLocation : .school
    routeSelectionView.setEndLocation(endType)
    routeSelectionView.setEndFixed(false)

    routeSelectionView.isHidden = false
    view.bringSubviewToFront(routeSelectionView)
    searchBar.isHidden = true
    [bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true }

    requestRoute(to: selectedPlace)
}
@objc private func backFromRouteSelection() {
    routeSelectionView.isHidden = true
    searchBar.isHidden = false

    guard let selectedPlace = allPlaces.first(where: { $0.placeId == selectedPlaceId }) else {
        return
    }

   
    if let routeVC = routeDetailVC {
        routeVC.view.removeFromSuperview()
        routeVC.removeFromParent()
        routeDetailVC = nil
    }

   
    resetUIForNewSelection()

    
    currentPlaceDetail = nil
    viewModel.fetchPlaceDetail(placeId: selectedPlace.placeId)
    fetchReviews(placeId: selectedPlace.placeId)
    viewModel.fetchRouteSilently(to: selectedPlace)

   
    placeDetailView.configure(
        with: MapPlaceDetailModel(
            placeId: selectedPlace.placeId,
            placeName: selectedPlace.placeName,
            address: selectedPlace.address,
            roadAddress: selectedPlace.address,
            latitude: selectedPlace.latitude,
            longitude: selectedPlace.longitude,
            categoryGroupName: "",
            categoryName: selectedPlace.categoryName,
            phone: "",
            placeUrl: "",
            reviewCount: 0,
            recommendCount: 0,
            recommended: false
        ),
        distanceText: "",
        timeText: "",
        reviews: self.viewModel.reviews
    )

    placeDetailView.isHidden = false
    bottomSheetView.isHidden = true
    recentSearchView.isHidden = true

   
    placeDetailView.setNeedsLayout()
    placeDetailView.layoutIfNeeded()

    detailSheetHeight?.update(offset: detailMinHeight)

    UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
    }
}

private func requestRoute(to selectedPlace: MapPlaceData) {


    if isStartFixedToPin {
        switch endLocationType {
        case .currentLocation:
            if let currentLocation {
                viewModel.fetchRouteFromPlace(
                    start: selectedPlace,
                    endType: .currentLocation,
                    currentLocation: currentLocation
                )
            } else {
                pendingRoutePlace = selectedPlace
                locationManager.requestLocation()
            }

        case .school:
            viewModel.fetchRouteFromPlace(
                start: selectedPlace,
                endType: .school,
                currentLocation: currentLocation
            )
        }
        return
    }

    switch startLocationType {
    case .school:
        routeSelectionView.setStartLocation(.school)
        viewModel.fetchRoute(to: selectedPlace)

    case .currentLocation:
        routeSelectionView.setStartLocation(.currentLocation)

        if let currentLocation {
            viewModel.currentLocation = (
                lat: currentLocation.coordinate.latitude,
                lng: currentLocation.coordinate.longitude
            )
            viewModel.fetchRouteFromCurrentLocation(to: selectedPlace)
        } else {
           
            pendingRoutePlace = selectedPlace
            locationManager.requestLocation()
        }
    }
}

private func setupMap() {
    mapWrapperView.layoutIfNeeded()
    mapWrapperView.subviews.forEach { $0.removeFromSuperview() }
    let container = KMViewContainer(frame: mapWrapperView.bounds)
    container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapWrapperView.addSubview(container)
    self.mapContainer = container
    let controller = KMController(viewContainer: container)
    controller.delegate = self
    self.mapController = controller
    mapController?.prepareEngine()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        self?.mapController?.activateEngine()
    }
}

public func addViews() {
    let defaultPoint = MapPoint(longitude: schoolFrontLng, latitude: schoolFrontLat)
    mapController?.addView(
        MapviewInfo(
            viewName: "mapview",
            viewInfoName: "map",
            defaultPosition: defaultPoint,
            defaultLevel: 17
        )
    )
}

public func addViewSucceeded(_ viewName: String, viewInfoName: String) {
    guard let view = mapController?.getView("mapview") as? KakaoMap else {
        return
    }

    view.eventDelegate = self

    let defaultPoint = MapPoint(longitude: schoolFrontLng, latitude: schoolFrontLat)
    view.moveCamera(
        CameraUpdate.make(target: defaultPoint, zoomLevel: 17, mapView: view)
    )
    createPoiStyle()

    let shapeManager = view.getShapeManager()

    let perLevelStyle = PerLevelPolylineStyle(
        bodyColor: UIColor.color.gomsPrimary.color,
        bodyWidth: 10,
        strokeColor: UIColor.white.withAlphaComponent(0.3),
        strokeWidth: 2,
        level: 0
    )

    let polylineStyle = PolylineStyle(styles: [perLevelStyle])
    let styleSet = PolylineStyleSet(styleSetID: "routeStyle", styles: [polylineStyle])

    shapeManager.addPolylineStyleSet(styleSet)

  
    _ = shapeManager.addShapeLayer(layerID: "routeLayer", zOrder: 9999)
    let manager = view.getLabelManager()

    if let existingLayer = manager.getLabelLayer(layerID: "poiLayer") {
        let ids = existingLayer.getAllPois()?.map { $0.itemID } ?? []
        existingLayer.removePois(poiIDs: ids)
    }

    if let existingActiveLayer = manager.getLabelLayer(layerID: "activePoiLayer") {
        let ids = existingActiveLayer.getAllPois()?.map { $0.itemID } ?? []
        existingActiveLayer.removePois(poiIDs: ids)
    }

    let _ = manager.addLabelLayer(option: LabelLayerOptions(layerID: "activePoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 20001))

    fetchPlaceList()
}

private func createPoiStyle() {
   
    func resizedImage(_ image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    guard let view = mapController?.getView("mapview") as? KakaoMap else {
        return
    }

    let manager = view.getLabelManager()

    let categories: [String] = [
        "MT1",
        "CS2",
        "AT4",
        "CT1",
        "FD6",
        "CE7",
        "HP8",
        "PM9"
    ]

    for styleID in categories {
        let image: UIImage
        switch styleID {
        case "MT1": image = FeatureAsset.Images.mt1.image
        case "CS2": image = FeatureAsset.Images.mt1.image
        case "AT4": image = FeatureAsset.Images.at4.image
        case "CT1": image = FeatureAsset.Images.ct1.image
        case "FD6": image = FeatureAsset.Images.fd6.image
        case "CE7": image = FeatureAsset.Images.ce7.image
        case "HP8": image = FeatureAsset.Images.hp8.image
        case "PM9": image = FeatureAsset.Images.pm9.image
        default: continue
        }
        let resized = resizedImage(image, size: CGSize(width: image.size.width * 0.5, height: image.size.height * 0.5))
        let iconStyle = PoiIconStyle(symbol: resized, anchorPoint: CGPoint(x: 0.5, y: 0.5))
        let poiStyle = PoiStyle(styleID: styleID, styles: [PerLevelPoiStyle(iconStyle: iconStyle, level: 0)])
        manager.addPoiStyle(poiStyle)
    }

    let defaultImage = FeatureAsset.Images.mypoint.image
    let activeIconStyle = PoiIconStyle(symbol: defaultImage, anchorPoint: CGPoint(x: 0.5, y: 0.5))
    let activeStyle = PoiStyle(styleID: "activePinStyle", styles: [PerLevelPoiStyle(iconStyle: activeIconStyle, level: 0)])
    manager.addPoiStyle(activeStyle)

    
    let baseImage = FeatureAsset.Images.mypoint.image
    let pulseImage = imageWithAlpha(baseImage, alpha: 0.3)
    func imageWithAlpha(_ image: UIImage, alpha: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale

        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size), blendMode: .normal, alpha: alpha)
        }
    }
    let baseSize = baseImage.size
    let scale: CGFloat = 1.7
    let resizedPulse = resizedImage(
        pulseImage,
        size: CGSize(
            width: baseSize.width * scale,
            height: baseSize.height * scale
        )
    )
    let pulseIconStyle = PoiIconStyle(symbol: resizedPulse, anchorPoint: CGPoint(x: 0.5, y: 0.5))
    let pulseStyle = PoiStyle(styleID: "pulseStyle", styles: [PerLevelPoiStyle(iconStyle: pulseIconStyle, level: 0)])
    manager.addPoiStyle(pulseStyle)
}

    private func moveCamera(to place: MapPlaceData) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }

        let point = MapPoint(
            longitude: place.longitude,
            latitude: place.latitude
        )
        
        let update = CameraUpdate.make(
            target: point,
            zoomLevel: 17,
            mapView: map
        )

        var options = CameraAnimationOptions()
        options.durationInMillis = 280
        options.autoElevation = true
        options.consecutive = false

        map.animateCamera(cameraUpdate: update, options: options)
    }

private func showActiveMarker(for place: MapPlaceData) {
    guard let map = mapController?.getView("mapview") as? KakaoMap else { return }

    let manager = map.getLabelManager()
    guard let activeLayer = manager.getLabelLayer(layerID: "activePoiLayer") else { return }

    let ids = activeLayer.getAllPois()?.map { $0.itemID } ?? []
    activeLayer.removePois(poiIDs: ids)

    let styleID = styleIDForCategory(place.categoryName)
    let option = PoiOptions(styleID: styleID, poiID:"active_\(place.placeId)")
    option.clickable = false

    if let poi = activeLayer.addPoi(
        option: option,
        at: MapPoint(longitude: place.longitude, latitude: place.latitude)
    ) {
        poi.show()
    }
}

public func kakaoMapDidTap(kakaoMap: KakaoMap, point: CGPoint) {
}

public func kakaoMap(_ kakaoMap: KakaoMap, didTap poi: Poi) {
    let coord = poi.position.wgsCoord
    handlePoiSelection(latitude: coord.latitude, longitude: coord.longitude, kakaoMap: kakaoMap)
}

public func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
    if layerID == "activePoiLayer" || poiID.hasPrefix("active_") {
        return
    }

    let coord = position.wgsCoord
    handlePoiSelection(latitude: coord.latitude, longitude: coord.longitude, kakaoMap: kakaoMap)
}

private func handlePoiSelection(latitude: Double, longitude: Double, kakaoMap: KakaoMap) {
        
        if let map = mapController?.getView("mapview") as? KakaoMap {
            let manager = map.getShapeManager()
            if let layer = manager.getShapeLayer(layerID: "routeLayer") {
                layer.removeMapPolylineShape(shapeID: "routeShape")
                layer.removeMapPolylineShape(shapeID: "routeGlowShape")
            }
        }
    guard let nearestPlace = viewModel.findNearestPlace(lat: latitude, lon: longitude) else {
        return
    }

    let dist = distance(
        lat1: latitude,
        lon1: longitude,
        lat2: nearestPlace.latitude,
        lon2: nearestPlace.longitude
    )

    if dist > distanceThreshold {
        return
    }

    self.selectedPlaceId = nearestPlace.placeId
    self.currentPlaceDetail = nil

    moveCamera(to: nearestPlace)
    showActiveMarker(for: nearestPlace)

    if let routeVC = self.routeDetailVC {
        routeVC.view.removeFromSuperview()
        routeVC.removeFromParent()
        self.routeDetailVC = nil

        self.routeSelectionView.endLocationLabel.text = "    \(nearestPlace.placeName)"
        self.viewModel.fetchPlaceDetail(placeId: nearestPlace.placeId)
        self.fetchReviews(placeId: nearestPlace.placeId)
        self.viewModel.fetchRouteSilently(to: nearestPlace)
        self.resetUIForNewSelection()
        self.showDetailView(with: nearestPlace)
        return
    }

    if !self.routeSelectionView.isHidden {
        self.routeSelectionView.endLocationLabel.text = "    \(nearestPlace.placeName)"
        self.requestRoute(to: nearestPlace)
        return
    }

    self.resetUIForNewSelection()
    self.placeDetailView.isHidden = false
    self.bottomSheetView.isHidden = true
    self.recentSearchView.isHidden = true
    self.searchBar.isHidden = false
    self.showDetailView(with: nearestPlace)
    self.placeDetailView.setNeedsLayout()
    self.placeDetailView.layoutIfNeeded()
    self.viewModel.fetchHotPlaces()
    self.viewModel.fetchRecommendedPlaces()

    if let activeLayer = kakaoMap.getLabelManager().getLabelLayer(layerID: "activePoiLayer") {
        let ids = activeLayer.getAllPois()?.map { $0.itemID } ?? []
        activeLayer.removePois(poiIDs: ids)
        let styleID = styleIDForCategory(nearestPlace.categoryName)
        let option = PoiOptions(styleID: styleID, poiID: "active_\(nearestPlace.placeId)")
        option.clickable = false
        if let poi = activeLayer.addPoi(
            option: option,
            at: MapPoint(longitude: nearestPlace.longitude, latitude: nearestPlace.latitude)
        ) {
            poi.show()
        }
    }
}


private func drawRoute() {
    guard let map = mapController?.getView("mapview") as? KakaoMap,
          let route = viewModel.routeResult?.routes.first else { return }

    let manager = map.getShapeManager()

    guard let layer = manager.getShapeLayer(layerID: "routeLayer") else { return }

    layer.removeMapPolylineShape(shapeID: "routeShape")
    layer.removeMapPolylineShape(shapeID: "routeGlowShape")

    var points: [MapPoint] = []

    for section in route.sections {
        for road in section.roads {
            let vertexes = road.vertexes
            for i in stride(from: 0, to: vertexes.count, by: 2) {
                guard i + 1 < vertexes.count else { continue }
                let lng = vertexes[i]
                let lat = vertexes[i + 1]
                points.append(MapPoint(longitude: lng, latitude: lat))
            }
        }
    }

    guard !points.isEmpty else { return }

    let polyline = MapPolyline(line: points, styleIndex: 0)

    let options = MapPolylineShapeOptions(
        shapeID: "routeShape",
        styleID: "routeStyle",
        zOrder: 9999
    )
    options.polylines = [polyline]

    if let shape = layer.addMapPolylineShape(options) {
        shape.show()

        
        let glowStyle = PerLevelPolylineStyle(
            bodyColor: UIColor.color.gomsPrimary.color.withAlphaComponent(0.3),
            bodyWidth: 16,
            strokeColor: UIColor.clear,
            strokeWidth: 0,
            level: 0
        )
        let glowStyleSet = PolylineStyleSet(styleSetID: "routeGlow", styles: [PolylineStyle(styles: [glowStyle])])
        manager.addPolylineStyleSet(glowStyleSet)

        let glowPolyline = MapPolyline(line: points, styleIndex: 0)
        let glowOptions = MapPolylineShapeOptions(
            shapeID: "routeGlowShape",
            styleID: "routeGlow",
            zOrder: 9998
        )
        glowOptions.polylines = [glowPolyline]
        layer.addMapPolylineShape(glowOptions)?.show()
    }
}


deinit {
    mapController?.pauseEngine()
    mapController?.resetEngine()
    mapController = nil
}
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = tableView == recentSearchView.tableView ? dummyRecentSearches.count : viewModel.reviews.count
    return count
}
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentSearchView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapRecentSearchCell", for: indexPath) as! MapRecentSearchCell
            let place = dummyRecentSearches[indexPath.row]
            let dateText: String

            if self.isShowingRecentSearches,
               let item = viewModel.recentSearches.first(where: { $0.placeId == place.placeId }) {
                dateText = formatDate(item.searchedAt)
            } else {
                dateText = ""
            }

            cell.configure(model: place, date: dateText)
            cell.backgroundColor = .clear
            cell.onDeleteTap = { [weak self, weak tableView] in
                guard let self = self, let tableView = tableView, let currentIndexPath = tableView.indexPath(for: cell) else { return }
                guard self.isShowingRecentSearches else { return }
                guard currentIndexPath.row < self.dummyRecentSearches.count else { return }

                let placeId = self.dummyRecentSearches[currentIndexPath.row].placeId
                self.viewModel.removeRecentSearch(placeId: placeId)

                self.dummyRecentSearches = self.viewModel.recentSearches.compactMap { item in
                    self.allPlaces.first(where: { $0.placeId == item.placeId })
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapReviewCell.identifier, for: indexPath) as! MapReviewCell
            cell.configure(with: viewModel.reviews[indexPath.row])

            let review = viewModel.reviews[indexPath.row]
            let isMyReview = review.isMine ?? false
            cell.setDeleteButtonHidden(!isMyReview)
            cell.setReportButtonHidden(isMyReview)
        cell.onDeleteTap = { [weak self, weak tableView] in
            guard let self = self else { return }
            guard let tableView = tableView else { return }
            guard let currentIndexPath = tableView.indexPath(for: cell) else { return }
            guard currentIndexPath.row < self.viewModel.reviews.count else { return }

            let reviewToDelete = self.viewModel.reviews[currentIndexPath.row]
            ReviewAlert.show(in: self, title: "후기 삭제", message: "작성하신 후기를 정말 삭제하시겠습니까?") { _ in
                self.placeDetailView.isUserInteractionEnabled = false
                self.viewModel.deleteReview(reviewId: reviewToDelete.reviewId) { [weak self] success in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.placeDetailView.isUserInteractionEnabled = true
                    }
                    guard success else {
                        DispatchQueue.main.async {
                            ReviewAlert.showSingle(
                                in: self,
                                title: "알림",
                                message: "후기 삭제에 실패했습니다.",
                                buttonTitle: "확인"
                            )
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.fetchReviews(placeId: self.selectedPlaceId)
                        self.viewModel.fetchPlaceDetail(placeId: self.selectedPlaceId)
                        self.viewModel.fetchHotPlaces()
                        self.viewModel.fetchRecommendedPlaces()
                        self.placeDetailView.tableView.reloadData()
                    }
                }
            }
        }
        cell.onReportTap = { [weak self] in
            guard let self = self else { return }
            guard indexPath.row < self.viewModel.reviews.count else { return }
            let review = self.viewModel.reviews[indexPath.row]
            ReviewAlert.show(in: self, title: "후기 신고", message: "") { reason in
                guard let reason = reason else { return }
                self.viewModel.reportReview(reviewId: review.reviewId, reason: reason) { [weak self] success in
                    guard let self = self else { return }
                    guard success else {
                        DispatchQueue.main.async {
                            ReviewAlert.showSingle(
                                in: self,
                                title: "알림",
                                message: "이미 해당 후기를 신고했습니다.",
                                buttonTitle: "취소"
                            )
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.placeDetailView.isUserInteractionEnabled = false
                        ReviewAlert.show(
                            in: self,
                            title: "신고 완료",
                            message: "신고가 정상적으로 접수되었습니다."
                        ) { [weak self] _ in
                            guard let self = self else { return }
                            self.placeDetailView.isUserInteractionEnabled = true
                            self.backToHome()
                        }
                    }
                }
            }
        }
        return cell
    }
}
public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == recentSearchView.tableView {
        let selectedData = dummyRecentSearches[indexPath.row]
        viewModel.addRecentSearch(placeId: selectedData.placeId)
        recentSearchView.isHidden = true
        searchBar.updateState(.home)
        searchBar.textField.text = selectedData.placeName
        view.endEditing(true)

        self.selectedPlaceId = selectedData.placeId
        self.resetUIForNewSelection()
        moveCamera(to: selectedData)
        showActiveMarker(for: selectedData)

        placeDetailView.isHidden = false
        bottomSheetView.isHidden = true
        recentSearchView.isHidden = true
        searchBar.isHidden = false

        self.showDetailView(with: selectedData)

        viewModel.fetchHotPlaces()
        viewModel.fetchRecommendedPlaces()

    }
}
}

extension MapViewController {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        guard let location = locations.last else { return }
        currentLocation = location
       

        viewModel.currentLocation = (
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
        showCurrentLocationMarker(location)

        if let pendingPlace = pendingRoutePlace {
    

            if isStartFixedToPin {
                viewModel.fetchRouteFromPlace(
                    start: pendingPlace,
                    endType: .currentLocation,
                    currentLocation: location
                )
            } else {
                viewModel.fetchRouteFromCurrentLocation(to: pendingPlace)
            }

            pendingRoutePlace = nil
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            startLocationType = .school
            endLocationType = .school
            routeSelectionView.setStartLocation(.school)
            routeSelectionView.setEndLocation(.school)
        @unknown default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pendingRoutePlace = nil
        startLocationType = .school
        endLocationType = .school
        routeSelectionView.setStartLocation(.school)
        routeSelectionView.setEndLocation(.school)
    }
}

    
    
