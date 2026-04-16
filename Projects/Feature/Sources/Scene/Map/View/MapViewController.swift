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

public final class MapViewController: UIViewController, MapControllerDelegate, KakaoMapEventDelegate {
    private let viewModel = MapViewModel()
    
    // MARK: - Properties

    private let distanceThreshold: Double = 0.001
    
    
    
    private var mapContainer: KMViewContainer?
    private var mapController: KMController?
    private let mapWrapperView = UIView()
    
    private var allPlaces: [MapPlaceData] = []
    private var dummyRecentSearches: [MapPlaceData] = [] {
        didSet { self.recentSearchView.tableView.reloadData() }
    }
    
    private var dummyReviews: [MapReview] = [] {
        didSet {
            if let currentDetail = self.currentPlaceDetail {
                self.placeDetailView.updateReviewCount(dummyReviews.count, recommendCount: currentDetail.recommendCount)
            }
            self.placeDetailView.tableView.reloadData()
        }
    }
    
    private let routeSelectionView = MapRouteSelectionView().then { $0.isHidden = true }
    private let searchBar = MapSearchBar()
    private let recentSearchView = MapRecentSearchView().then {
        $0.isHidden = true
        $0.backgroundColor = .color.background.color
        $0.tableView.backgroundColor = .color.background.color
    }
    private let bottomSheetView = MapBottomSheetView()
    private let placeDetailView = MapPlaceDetailView().then {
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    
    private var bottomSheetHeight: Constraint?
    private var detailSheetHeight: Constraint?
    private let defaultHeight: CGFloat = 240
    private let detailMinHeight: CGFloat = 225
    private var selectedPlaceId: Int = -1
    private var currentPlaceDetail: MapPlaceDetailModel?


    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
        setupGesture()
        setupActions()
        setupReviewWriteAction()

        setupMap()
        bindViewModel()
        setupBottomSheetBinding()
        fetchPlaceList()
        viewModel.fetchHotPlaces()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapController?.pauseEngine()
    }

    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .color.background.color
        view.addSubview(mapWrapperView)
        [bottomSheetView, recentSearchView, routeSelectionView, placeDetailView, searchBar].forEach { view.addSubview($0) }
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
        [recentSearchView.tableView, placeDetailView.tableView].forEach { $0.delegate = self; $0.dataSource = self }
    }
    
    private func setupActions() {
        placeDetailView.closeButton.addTarget(self, action: #selector(hideDetailView), for: .touchUpInside)
        placeDetailView.arriveButton.addTarget(self, action: #selector(didTapArriveRoute), for: .touchUpInside)
        placeDetailView.startRouteButton.addTarget(self, action: #selector(didTapStartRoute), for: .touchUpInside)
        routeSelectionView.backButton.addTarget(self, action: #selector(backFromRouteSelection), for: .touchUpInside)
        bottomSheetView.onCardTapped = { [weak self] placeId in
            guard let self = self else { return }
            if let selected = self.allPlaces.first(where: { $0.placeId == placeId }) {
                self.showDetailView(with: selected)
            }
        }
        searchBar.textField.addTarget(self, action: #selector(didTapSearchBar), for: .editingDidBegin)
        searchBar.textField.addTarget(self, action: #selector(performSearch), for: .editingDidEndOnExit)
        searchBar.backButton.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        placeDetailView.onHeartToggled = { [weak self] isSelected in
            guard let self = self, self.selectedPlaceId != -1 else { return }
            self.viewModel.toggleRecommend(placeId: self.selectedPlaceId, isSelected: isSelected) {
                self.viewModel.fetchHotPlaces()
            }
        }
        routeSelectionView.onCardTapped = { [weak self] routeTitle in
            let detailVC = MapRouteDetailViewController(); detailVC.routeTypeTitle = routeTitle; detailVC.modalPresentationStyle = .overFullScreen
            detailVC.onDismiss = { [weak self] in self?.routeSelectionView.isHidden = false }
            self?.routeSelectionView.isHidden = true; self?.present(detailVC, animated: true)
        }
    }
    
    private func setupReviewWriteAction() { placeDetailView.reviewWriteButton.addTarget(self, action: #selector(didTapReviewWrite), for: .touchUpInside) }

    // MARK: - Networking
    private func fetchPlaceList() {
        viewModel.fetchAllPlaces()
    }
    
    
    private func fetchReviews(placeId: Int) {
        viewModel.fetchReviews(placeId: placeId)
    }

    @objc private func performSearch() {
        guard let keyword = searchBar.textField.text, !keyword.isEmpty else { return }

        viewModel.searchPlace(keyword: keyword)

        // UI 상태 변경
        recentSearchView.isHidden = false
        bottomSheetView.isHidden = true
        placeDetailView.isHidden = true

        // 키보드 내리기
        view.endEditing(true)
    }

    @objc private func didTapReviewWrite() {
        guard let detailData = currentPlaceDetail else { return }
        self.navigationController?.pushViewController(MapReviewWriteViewController(placeData: detailData), animated: true)
    }

    // MARK: - Marker Rendering
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
            option.clickable = false
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

    // MARK: - Gestures
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let isDetail = gesture.view == placeDetailView
        let translation = gesture.translation(in: view)
        let currentHeight = isDetail ? placeDetailView.frame.height : bottomSheetView.frame.height
        let newHeight = currentHeight - translation.y
        let minH = isDetail ? detailMinHeight : defaultHeight
        let maxH = view.frame.height - (searchBar.frame.maxY + 20)
        
        if gesture.state == .changed {
            let clampedHeight = max(minH, min(newHeight, maxH))
            if isDetail { detailSheetHeight?.update(offset: clampedHeight) }
            else { bottomSheetHeight?.update(offset: clampedHeight) }
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: view).y
            let targetHeight: CGFloat = (velocity < -500 || (velocity <= 500 && newHeight > (minH + maxH) / 2)) ? maxH : minH
            UIView.animate(withDuration: 0.3) {
                if isDetail { self.detailSheetHeight?.update(offset: targetHeight) }
                else { self.bottomSheetHeight?.update(offset: targetHeight) }
                self.view.layoutIfNeeded()
            }
        }
        gesture.setTranslation(.zero, in: view)
    }

    private func setupGesture() {
        bottomSheetView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        placeDetailView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }

    // MARK: - View Transition
    private func showDetailView(with data: MapPlaceData? = nil) {
        self.bottomSheetView.isHidden = true

        if let data = data {
            self.selectedPlaceId = data.placeId
            viewModel.fetchPlaceDetail(placeId: data.placeId)
            fetchReviews(placeId: data.placeId)
        } else {
            let detailModel = MapMockData.detailExample
            self.selectedPlaceId = detailModel.placeId
            self.currentPlaceDetail = detailModel
            fetchReviews(placeId: self.selectedPlaceId)

            let schoolLat = 35.1425
            let schoolLng = 126.8005

            let dist = viewModel.distance(
                lat1: schoolLat,
                lon1: schoolLng,
                lat2: detailModel.latitude,
                lon2: detailModel.longitude
            )

            let meters = dist * 111000
            let minutes = Int(meters / 80)

            let distanceText = "\(Int(meters))m"
            let timeText = "\(minutes)분"

            placeDetailView.configure(
                with: detailModel,
                distanceText: distanceText,
                timeText: timeText
            )
            updateViewVisibility()
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
            self.dummyRecentSearches = self.viewModel.searchResults

            let keyword = self.searchBar.textField.text ?? ""
            self.recentSearchView.titleLabel.text = self.viewModel.searchResults.isEmpty
                ? "검색 결과가 없습니다"
                : "'\(keyword)' 검색 결과"

            // 검색 결과 표시 보장
            self.recentSearchView.isHidden = false
            self.bottomSheetView.isHidden = true
        }

        viewModel.onReviewsUpdated = { [weak self] in
            self?.dummyReviews = self?.viewModel.reviews ?? []
            self?.updateBottomSheet()
        }

        viewModel.onDetailUpdated = { [weak self] in
            guard let self = self, let detail = self.viewModel.currentPlaceDetail else { return }

            self.selectedPlaceId = detail.placeId
            self.currentPlaceDetail = detail

            self.placeDetailView.configure(
                with: detail,
                distanceText: self.viewModel.distanceText,
                timeText: self.viewModel.timeText
            )

            self.updateViewVisibility()
        }
        viewModel.onHotPlacesUpdated = { [weak self] in
            self?.updateBottomSheet()
        }
    }

    private func setupBottomSheetBinding() {
        // 초기 데이터 세팅 (빈 상태 방지)
        updateBottomSheet()
    }

    private func updateBottomSheet() {
        let popular: [MapCardData] = viewModel.hotPlaces.prefix(5).map { place in
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

        let recommended: [MapCardData] = []

        let reviews: [MapCardData] = dummyReviews.map { review in
            return MapCardData(
                id: review.reviewId,
                name: "",
                address: "",
                category: "",
                reviewCount: 0,
                recommendCount: 0,
                isFavorite: false
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
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func hideDetailView() {
        if let view = mapController?.getView("mapview") as? KakaoMap, let activeLayer = view.getLabelManager().getLabelLayer(layerID: "activePoiLayer") {
            activeLayer.removePois(poiIDs: activeLayer.getAllPois()?.map { $0.itemID } ?? [])
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.detailSheetHeight?.update(offset: 0)
            self.view.layoutIfNeeded()
        }) { _ in
            self.placeDetailView.isHidden = true
            self.bottomSheetView.isHidden = false
            self.selectedPlaceId = -1
            self.currentPlaceDetail = nil
        }
    }

    @objc private func backToHome() { hideDetailView(); recentSearchView.isHidden = true; searchBar.updateState(.home); searchBar.isHidden = false; searchBar.textField.text = ""; view.endEditing(true) }
    @objc private func didTapSearchBar() { if !placeDetailView.isHidden { hideDetailView() }; searchBar.updateState(.search); recentSearchView.isHidden = false; recentSearchView.titleLabel.text = "최근 검색" }
    @objc private func didTapArriveRoute() { routeSelectionView.isHidden = false; searchBar.isHidden = true; [bottomSheetView, placeDetailView, recentSearchView].forEach { $0.isHidden = true } }
    @objc private func didTapStartRoute() { didTapArriveRoute() }
    @objc private func backFromRouteSelection() { routeSelectionView.isHidden = true; placeDetailView.isHidden = false; searchBar.isHidden = false; detailSheetHeight?.update(offset: detailMinHeight); UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() } }
    
    // MARK: - Kakao Maps Setup
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
        let defaultPoint = MapPoint(longitude: 126.8005, latitude: 35.1425)
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

        let defaultPoint = MapPoint(longitude: 126.8005, latitude: 35.1425)
        view.moveCamera(
            CameraUpdate.make(target: defaultPoint, zoomLevel: 17, mapView: view)
        )
        createPoiStyle()
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
            let resized = resizedImage(image, size: CGSize(width: 32, height: 32))
            let iconStyle = PoiIconStyle(symbol: resized, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let poiStyle = PoiStyle(styleID: styleID, styles: [PerLevelPoiStyle(iconStyle: iconStyle, level: 0)])
            manager.addPoiStyle(poiStyle)
        }


        let defaultImage = UIImage(systemName: "mappin.and.ellipse")!
        let activeIconStyle = PoiIconStyle(symbol: defaultImage, anchorPoint: CGPoint(x: 0.5, y: 1.0))
        let activeStyle = PoiStyle(styleID: "activePinStyle", styles: [PerLevelPoiStyle(iconStyle: activeIconStyle, level: 0)])
        manager.addPoiStyle(activeStyle)
    }

    private func moveCamera(to place: MapPlaceData) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }

        let point = MapPoint(
            longitude: place.longitude,
            latitude: place.latitude
        )

        let update: CameraUpdate = CameraUpdate.make(
            target: point,
            zoomLevel: 17,
            mapView: map
        )

        map.moveCamera(update)
    }

    private func showActiveMarker(for place: MapPlaceData) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }

        let manager = map.getLabelManager()
        guard let activeLayer = manager.getLabelLayer(layerID: "activePoiLayer") else { return }

        // 기존 제거
        let ids = activeLayer.getAllPois()?.map { $0.itemID } ?? []
        activeLayer.removePois(poiIDs: ids)

        let styleID = styleIDForCategory(place.categoryName)
        let option = PoiOptions(styleID: styleID, poiID: "active_\(place.placeId)")
        option.clickable = false

        if let poi = activeLayer.addPoi(
            option: option,
            at: MapPoint(longitude: place.longitude, latitude: place.latitude)
        ) {
            poi.show()
        }
    }

    public func kakaoMapDidTap(kakaoMap: KakaoMap, point: CGPoint) {
       
        return
    }

    // MARK: - Kakao 기본 POI 클릭 처리
    public func kakaoMap(_ kakaoMap: KakaoMap, didTap poi: Poi) {

        let coord = poi.position
        let wgs = coord.wgsCoord

        guard let nearestPlace = viewModel.findNearestPlace(lat: wgs.latitude, lon: wgs.longitude) else {
            return
        }

        let dist = viewModel.distance(lat1: wgs.latitude, lon1: wgs.longitude, lat2: nearestPlace.latitude, lon2: nearestPlace.longitude)
        if dist > distanceThreshold {
            return
        }

        showDetailView(with: nearestPlace)

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

    public func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
       
        
        if layerID == "activePoiLayer" || poiID.hasPrefix("active_") {
            
            return
        }

       
        let wgs = position.wgsCoord
        guard let nearestPlace = viewModel.findNearestPlace(lat: wgs.latitude, lon: wgs.longitude) else {
            return
        }

        let dist = viewModel.distance(lat1: wgs.latitude, lon1: wgs.longitude, lat2: nearestPlace.latitude, lon2: nearestPlace.longitude)
        if dist > distanceThreshold {
            return
        }

        showDetailView(with: nearestPlace)

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

    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        mapController = nil
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = tableView == recentSearchView.tableView ? dummyRecentSearches.count : dummyReviews.count
        return count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recentSearchView.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapRecentSearchCell", for: indexPath) as! MapRecentSearchCell
            cell.configure(model: dummyRecentSearches[indexPath.row], date: "26.04.11"); cell.backgroundColor = .clear
            cell.onDeleteTap = { [weak self, weak tableView] in
                guard let self = self, let tableView = tableView, let currentIndexPath = tableView.indexPath(for: cell) else { return }
                self.dummyRecentSearches.remove(at: currentIndexPath.row); tableView.deleteRows(at: [currentIndexPath], with: .fade)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MapReviewCell.identifier, for: indexPath) as! MapReviewCell
            cell.configure(with: dummyReviews[indexPath.row])
            cell.onDeleteTap = { [weak self] in
                guard let self = self, let currentIndexPath = tableView.indexPath(for: cell) else { return }
                ReviewAlert.show(in: self, title: "후기 삭제", message: "작성하신 후기를 정말 삭제하시겠습니까?") {
                    let reviewToDelete = self.dummyReviews[currentIndexPath.row]
                    self.viewModel.deleteReview(reviewId: reviewToDelete.reviewId) { success in
                        if success {
                            self.dummyReviews.remove(at: currentIndexPath.row)
                        }
                    }
                }
            }
            cell.onReportTap = { [weak self] in guard let self = self else { return }; ReviewAlert.show(in: self, title: "후기 신고", message: "이 후기를 신고하시겠습니까?") { } }
            return cell
        }
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentSearchView.tableView {
            let selectedData = dummyRecentSearches[indexPath.row]
            recentSearchView.isHidden = true
            searchBar.updateState(.home)
            view.endEditing(true)

            moveCamera(to: selectedData)
            showActiveMarker(for: selectedData)

            showDetailView(with: selectedData)
        }
    }
}
